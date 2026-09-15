local tutor = {}
local sessions = {}
local prompt_path = debug.getinfo(1, "S").source:sub(2):gsub("init.lua$", "prompt.md")

local function project_root()
  if vim.b.tutor_root then
    return vim.b.tutor_root
  end
  local filename = vim.api.nvim_buf_get_name(0)
  local directory = vim.bo.buftype == "" and filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
  local result = vim.system({ "git", "-C", directory, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Tutor: Git リポジトリで実行してください。", vim.log.levels.WARN)
    return nil
  end
  return vim.trim(result.stdout)
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
  local root = project_root()
  if not root then
    return
  end
  local key = root .. "\n" .. provider
  local session = sessions[key]
  if session and vim.api.nvim_buf_is_valid(session.buffer) and vim.fn.jobwait({ session.job }, 0)[1] == -1 then
    show(session.buffer)
    return
  end
  local prompt = table.concat(vim.fn.readfile(prompt_path), "\n")
  local command = provider == "codex"
      and { provider, "--sandbox", "read-only", prompt }
    or { provider, "--permission-mode", "auto", prompt }
  local buffer = vim.api.nvim_create_buf(false, true)
  show(buffer)
  vim.b.tutor_root = root
  vim.bo.bufhidden = "hide"
  local job = vim.fn.jobstart(command, { term = true, cwd = root })
  if job <= 0 then
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.notify("Tutor: CLI を起動できませんでした。", vim.log.levels.ERROR)
    return
  end
  sessions[key] = { buffer = buffer, job = job }
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
  vim.api.nvim_create_user_command("TutorHide", function()
    if vim.b.tutor_root then
      vim.cmd.hide()
    end
  end, { desc = "学習用 AI の会話を維持してウィンドウを閉じる" })
end

return tutor
