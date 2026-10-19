local tutor = {}
local sessions = {}
local prompt_path = debug.getinfo(1, "S").source:sub(2):gsub("init.lua$", "prompt.md")
local state_directory = vim.fn.stdpath("state") .. "/tutor"

local function inside(directory, root)
  return directory == root or vim.startswith(directory, root .. "/")
end

-- learning.md を探して、会話の単位にするディレクトリを決める
local function context()
  if vim.b.tutor_root then
    return vim.b.tutor_root, vim.b.tutor_directory, vim.b.tutor_learning
  end
  local filename = vim.api.nvim_buf_get_name(0)
  local directory = vim.bo.buftype == "" and filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
  local result = vim.system({ "git", "-C", directory, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Tutor: Git リポジトリで実行してください。", vim.log.levels.WARN)
    return nil
  end
  local root = vim.trim(result.stdout)
  directory = vim.uv.fs_realpath(directory) or directory
  local learning = vim.fs.find("learning.md", {
    path = directory,
    upward = true,
    stop = vim.fs.dirname(root),
    type = "file",
  })[1]
  if learning then
    return root, vim.fs.dirname(learning), learning
  end
  local cwd = vim.uv.fs_realpath(vim.fn.getcwd()) or vim.fn.getcwd()
  return root, inside(cwd, root) and cwd or root, nil
end

local function realpath(path)
  local directory = vim.uv.fs_realpath(vim.fs.dirname(path))
  return directory and directory .. "/" .. vim.fs.basename(path) or path
end

-- 学習者が今見ているファイルを、AI が読める形で書き出す
local function describe(buffer)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lines = {
    "# 学習者が Neovim で開いているファイル",
    "",
    "- ファイル: " .. realpath(vim.api.nvim_buf_get_name(buffer)),
    "- カーソル: " .. cursor[1] .. " 行目 " .. (cursor[2] + 1) .. " 列目",
    "- 未保存の変更: " .. (vim.bo[buffer].modified and "あり" or "なし"),
    "- 更新日時: " .. os.date("%Y-%m-%d %H:%M:%S"),
    "",
    "## LSP の診断",
    "",
  }
  local diagnostics = vim.diagnostic.get(buffer)
  table.sort(diagnostics, function(a, b)
    return a.lnum < b.lnum or (a.lnum == b.lnum and a.col < b.col)
  end)
  if #diagnostics == 0 then
    table.insert(lines, "なし")
  end
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(lines, string.format(
      "- %d 行目 %d 列目 %s: %s%s",
      diagnostic.lnum + 1,
      diagnostic.col + 1,
      vim.diagnostic.severity[diagnostic.severity]:lower(),
      (diagnostic.message:gsub("\n", " ")),
      diagnostic.source and (" (" .. diagnostic.source .. ")") or ""
    ))
  end
  return lines
end

local function tracked_buffer()
  local buffer = vim.api.nvim_get_current_buf()
  if vim.bo[buffer].buftype ~= "" or vim.api.nvim_buf_get_name(buffer) == "" then
    return nil
  end
  return buffer
end

local function track()
  local buffer = tracked_buffer()
  if not buffer then
    return
  end
  local path = realpath(vim.api.nvim_buf_get_name(buffer))
  local lines
  for _, session in pairs(sessions) do
    if inside(path, session.root) and vim.fn.jobwait({ session.job }, 0)[1] == -1 then
      lines = lines or describe(buffer)
      vim.fn.writefile(lines, session.state)
    end
  end
end

local function show(buffer)
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(window) == buffer then
      vim.api.nvim_set_current_win(window)
      vim.cmd.startinsert()
      return
    end
  end
  vim.cmd("botright vsplit")
  vim.api.nvim_win_set_buf(0, buffer)
  vim.cmd.startinsert()
end

function tutor.start(provider)
  provider = provider == "" and "claude" or provider
  if provider ~= "codex" and provider ~= "claude" then
    vim.notify("Tutor: codex または claude を指定してください。", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable(provider) ~= 1 or vim.fn.executable("git") ~= 1 then
    vim.notify("Tutor: git と " .. provider .. " を PATH に用意してください。", vim.log.levels.ERROR)
    return
  end
  local root, directory, learning = context()
  if not root then
    return
  end
  local key = directory .. "\n" .. provider
  local session = sessions[key]
  if session and vim.api.nvim_buf_is_valid(session.buffer) and vim.fn.jobwait({ session.job }, 0)[1] == -1 then
    track()
    show(session.buffer)
    return
  end
  vim.fn.mkdir(state_directory, "p")
  local state = state_directory .. "/" .. vim.fn.getpid() .. "-" .. vim.fn.sha256(key):sub(1, 12) .. ".md"
  local current = tracked_buffer()
  vim.fn.writefile(current and describe(current) or { "まだ開いているファイルはありません。" }, state)
  local prompt = table.concat(vim.fn.readfile(prompt_path), "\n")
    .. "\n\n## この会話の learning.md\n\n"
    .. (learning and ("この会話では " .. learning .. " を使ってください。")
      or ("まだ learning.md はありません。Neovim の作業ディレクトリは " .. directory .. " です。"))
    .. "\n\n## 学習者が開いているファイル\n\n"
    .. state .. " に書いてあります。"
  local command = provider == "codex"
      and { provider, "--sandbox", "read-only", prompt }
    or { provider, "--add-dir", state_directory, "--permission-mode", "auto", prompt }
  local buffer = vim.api.nvim_create_buf(false, true)
  show(buffer)
  vim.b.tutor_root = root
  vim.b.tutor_directory = directory
  vim.b.tutor_learning = learning
  vim.bo.bufhidden = "hide"
  local job = vim.fn.jobstart(command, {
    term = true,
    cwd = directory,
    on_exit = function()
      os.remove(state)
    end,
  })
  if job <= 0 then
    os.remove(state)
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.notify("Tutor: CLI を起動できませんでした。", vim.log.levels.ERROR)
    return
  end
  sessions[key] = { buffer = buffer, job = job, root = root, state = state }
end

function tutor.setup()
  vim.api.nvim_create_user_command("TutorStart", function(options)
    tutor.start(options.args)
  end, {
    nargs = "?",
    complete = function(prefix)
      return vim.tbl_filter(function(provider)
        return vim.startswith(provider, prefix)
      end, { "claude", "codex" })
    end,
    desc = "Git リポジトリで学習用 AI の会話を開く",
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "WinLeave", "CursorHold", "BufWritePost", "DiagnosticChanged" }, {
    group = vim.api.nvim_create_augroup("tutor", { clear = true }),
    callback = track,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = "tutor",
    callback = function()
      for _, session in pairs(sessions) do
        os.remove(session.state)
      end
    end,
  })
  vim.api.nvim_create_user_command("TutorHide", function()
    if vim.b.tutor_root then
      vim.cmd.hide()
    end
  end, { desc = "学習用 AI の会話を維持してウィンドウを閉じる" })
end

return tutor
