-- lazy.nvim の更新を取り込む前に、差分を Claude にレビューさせる
local review = {}
local prompt_path = debug.getinfo(1, "S").source:sub(2):gsub("init.lua$", "prompt.md")
local state_directory = vim.fn.stdpath("state") .. "/plugin-review"
local max_input_bytes = 300 * 1024
local schema = vim.json.encode({
  type = "object",
  properties = {
    verdict = { type = "string", enum = { "ok", "suspicious" } },
    reasons = { type = "array", items = { type = "string" } },
  },
  required = { "verdict", "reasons" },
})
local labels = {
  ok = "ok",
  suspicious = "ブロック（Claude が不審と判断）",
  manual = "ブロック（Claude では確認できない）",
}
local queue = {}
local queued = {}
local reviewing = nil
local finished = {}

-- checker が fetch した結果のうち、まだ取り込んでいない更新を集める
local function updates()
  local list = {}
  for _, plugin in pairs(require("lazy.core.config").plugins) do
    local pending = plugin._.updates
    if pending and not plugin._.is_local and pending.from.commit and pending.to.commit then
      table.insert(list, {
        name = plugin.name,
        plugin = plugin,
        from = pending.from.commit,
        to = pending.to.commit,
        branch = pending.to.branch,
      })
    end
  end
  table.sort(list, function(a, b)
    return a.name < b.name
  end)
  return list
end

-- 同じコミット範囲を二度レビューしないよう、結果を範囲ごとに保存する
local function result_path(update)
  local name = update.name:gsub("[^%w._-]", "_")
  return string.format("%s/%s@%s..%s.json", state_directory, name, update.from:sub(1, 12), update.to:sub(1, 12))
end

local function read_result(update)
  local file = io.open(result_path(update), "r")
  if not file then
    return nil
  end
  local ok, result = pcall(vim.json.decode, file:read("*a"))
  file:close()
  return ok and type(result) == "table" and result or nil
end

local function write_result(update, verdict, reasons)
  vim.fn.mkdir(state_directory, "p")
  local file = assert(io.open(result_path(update), "w"))
  file:write(vim.json.encode({
    verdict = verdict,
    reasons = reasons,
    from = update.from,
    to = update.to,
    reviewed_at = os.date("%Y-%m-%d %H:%M:%S"),
  }))
  file:close()
end

local function git(update, args, callback)
  local command = vim.list_extend({ "git", "-C", update.plugin.dir }, args)
  vim.system(command, { text = true }, vim.schedule_wrap(callback))
end

-- 差分には外部の誰でも書ける文章が入るので、Claude にはツールを一切渡さない
local function ask(input, callback)
  vim.fn.mkdir(state_directory, "p")
  local command = {
    "claude",
    "-p",
    "--tools",
    "",
    "--strict-mcp-config",
    "--setting-sources",
    "",
    "--no-session-persistence",
    "--output-format",
    "json",
    "--json-schema",
    schema,
    table.concat(vim.fn.readfile(prompt_path), "\n"),
  }
  local options = { stdin = input, text = true, cwd = state_directory, timeout = 10 * 60 * 1000 }
  vim.system(command, options, vim.schedule_wrap(function(result)
    local ok, output = pcall(vim.json.decode, result.stdout or "")
    local answer = ok and type(output) == "table" and output.structured_output
    if result.code ~= 0 or type(answer) ~= "table" or not labels[answer.verdict] or answer.verdict == "manual" then
      callback(nil, { "claude の実行に失敗しました: " .. vim.trim(result.stderr or "") })
      return
    end
    callback(answer.verdict, type(answer.reasons) == "table" and answer.reasons or {})
  end))
end

local function examine(update, callback)
  git(update, { "log", "--no-color", "--format=%H %an <%ae>%n%B", update.from .. ".." .. update.to }, function(log)
    if log.code ~= 0 then
      callback(nil, { "git log に失敗しました: " .. vim.trim(log.stderr) })
      return
    end
    git(update, {
      "diff",
      "--no-color",
      "--no-ext-diff",
      "--no-textconv",
      "--submodule=short",
      update.from,
      update.to,
    }, function(diff)
      if diff.code ~= 0 then
        callback(nil, { "git diff に失敗しました: " .. vim.trim(diff.stderr) })
        return
      end
      local reasons = {}
      local patch = "\n" .. diff.stdout
      if patch:find("\nBinary files ", 1, true) then
        table.insert(reasons, "バイナリファイルの変更を含むため、中身を確認できません。")
      end
      if patch:find("\n[-+]Subproject commit ") then
        table.insert(reasons, "submodule の参照先が変わっているため、中身を確認できません。")
      end
      local build = update.plugin.build
      local input = table.concat({
        "# プラグイン: " .. update.name,
        "",
        "- URL: " .. (update.plugin.url or "不明"),
        "- 現在のコミット: " .. update.from,
        "- 更新先のコミット: " .. update.to,
        "- build: " .. (build == nil and "なし" or vim.inspect(build)),
        "",
        "## コミット一覧",
        "",
        log.stdout,
        "## 差分",
        "",
        diff.stdout,
      }, "\n")
      if #input > max_input_bytes then
        table.insert(reasons, string.format("差分が %d KB あり、レビューできる大きさを超えています。", math.floor(#input / 1024)))
      end
      if #reasons > 0 then
        callback("manual", reasons)
        return
      end
      ask(input, callback)
    end)
  end)
end

local function report()
  local counts = { ok = 0, blocked = 0, failed = 0 }
  for _, entry in ipairs(finished) do
    local kind = entry.verdict == "ok" and "ok" or entry.verdict and "blocked" or "failed"
    counts[kind] = counts[kind] + 1
  end
  local message = string.format(
    "PluginReview: %d 件の更新をレビューしました（ok %d 件、ブロック %d 件、失敗 %d 件）。:LazyReview で詳細を確認し、:LazyReviewedUpdate で ok のものを適用できます。",
    #finished,
    counts.ok,
    counts.blocked,
    counts.failed
  )
  finished = {}
  vim.notify(message, (counts.blocked > 0 or counts.failed > 0) and vim.log.levels.WARN or vim.log.levels.INFO)
end

local function advance()
  if reviewing then
    return
  end
  reviewing = table.remove(queue, 1)
  if not reviewing then
    if #finished > 0 then
      report()
    end
    return
  end
  local update = reviewing
  examine(update, function(verdict, reasons)
    -- 失敗は保存せず、次の check で再挑戦する
    if verdict then
      write_result(update, verdict, reasons)
    end
    queued[result_path(update)] = nil
    table.insert(finished, { name = update.name, verdict = verdict })
    reviewing = nil
    advance()
  end)
end

function review.start()
  if vim.fn.executable("claude") ~= 1 or vim.fn.executable("git") ~= 1 then
    vim.notify("PluginReview: git と claude を PATH に用意してください。", vim.log.levels.ERROR)
    return
  end
  for _, update in ipairs(updates()) do
    local path = result_path(update)
    if not queued[path] and not read_result(update) then
      queued[path] = true
      table.insert(queue, update)
    end
  end
  advance()
end

function review.show()
  local lines = { "# lazy.nvim の更新レビュー", "" }
  local list = updates()
  if #list == 0 then
    table.insert(lines, "取り込んでいない更新はありません。")
  end
  for _, update in ipairs(list) do
    local result = read_result(update)
    local status = result and labels[result.verdict] or queued[result_path(update)] and "レビュー待ち" or "未レビュー"
    vim.list_extend(lines, {
      string.format("## %s  %s..%s", update.name, update.from:sub(1, 7), update.to:sub(1, 7)),
      "",
      "- 結果: " .. status,
    })
    for _, reason in ipairs(result and result.reasons or {}) do
      table.insert(lines, "  - " .. (reason:gsub("\n", " ")))
    end
    if not result or result.verdict ~= "ok" then
      vim.list_extend(lines, {
        "- 差分: git -C " .. vim.fn.shellescape(update.plugin.dir) .. " log -p " .. update.from .. ".." .. update.to,
        "- 自分で確認して問題なければ :LazyReviewApprove " .. update.name,
      })
    end
    table.insert(lines, "")
  end
  vim.cmd("botright new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.modifiable = false
  vim.bo.filetype = "markdown"
end

function review.approve(name)
  for _, update in ipairs(updates()) do
    if update.name == name then
      write_result(update, "ok", { "手動で確認して承認しました。" })
      vim.notify("PluginReview: " .. name .. " の更新を承認しました。", vim.log.levels.INFO)
      return
    end
  end
  vim.notify("PluginReview: " .. name .. " に取り込んでいない更新はありません。", vim.log.levels.WARN)
end

-- レビューしたコミットを lockfile に書いてから restore するので、
-- その後 upstream が進んでいてもレビュー済みのコミットまでしか進まない
function review.apply()
  local lock = require("lazy.manage.lock")
  lock.load()
  local names = {}
  local skipped = {}
  for _, update in ipairs(updates()) do
    local result = read_result(update)
    if result and result.verdict == "ok" then
      local current = lock.lock[update.name] or {}
      lock.lock[update.name] = { branch = update.branch or current.branch, commit = update.to }
      table.insert(names, update.name)
    else
      table.insert(skipped, update.name)
    end
  end
  if #skipped > 0 then
    vim.notify(
      "PluginReview: レビューを通っていないため、次の更新は取り込みません: " .. table.concat(skipped, ", "),
      vim.log.levels.WARN
    )
  end
  if #names == 0 then
    vim.notify("PluginReview: 取り込める更新はありません。", vim.log.levels.INFO)
    return
  end
  require("lazy").restore({ plugins = names })
end

function review.setup()
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("plugin-review", { clear = true }),
    pattern = { "LazyCheck", "VeryLazy" },
    callback = function()
      review.start()
    end,
  })
  vim.api.nvim_create_user_command("LazyReview", review.show, { desc = "lazy.nvim の更新のレビュー結果を表示する" })
  vim.api.nvim_create_user_command("LazyReviewedUpdate", review.apply, {
    desc = "レビューで ok になった lazy.nvim の更新だけを取り込む",
  })
  vim.api.nvim_create_user_command("LazyReviewApprove", function(options)
    review.approve(options.args)
  end, {
    nargs = 1,
    complete = function(prefix)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, prefix)
      end, vim.tbl_map(function(update)
        return update.name
      end, updates()))
    end,
    desc = "ブロックされた lazy.nvim の更新を手動で承認する",
  })
end

return review
