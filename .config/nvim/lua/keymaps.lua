local keymap = vim.keymap.set

-- esc escでハイライトを削除
keymap("n", "<Esc><Esc>", ":nohlsearch<Return>", opts)

-- 折り返しで下にいけるようにする
-- カウントなしならgj, ありならm'
-- https://eiji.page/blog/neovim-remeber-jump-jk/
keymap("n", "j", function()
  if vim.v.count == 0 then
    return "gj"
  else
    return "m'" .. vim.v.count .. "j"
  end
end, { expr = true })

-- 折り返しで下にいけるようにする
-- カウントなしならgn, ありならm'
-- https://eiji.page/blog/neovim-remeber-jump-jk/
keymap("n", "k", function()
  if vim.v.count == 0 then
    return "gk"
  else
    return "m'" .. vim.v.count .. "k"
  end
end, { expr = true })

-- 相対パス,絶対パスを取得してコピー
vim.api.nvim_create_user_command('CopyRelativePath', function()
  vim.fn.setreg(vim.v.register, vim.fn.expand('%:p:.'))
end, {})

-- プロジェクトルート (.git) からの相対パスを取得してコピー
local function get_project_relative_path()
  local current_file = vim.fn.expand('%:p')
  -- .git ディレクトリを現在地から上に向かって探索
  local git_dir = vim.fs.find('.git', { path = current_file, upward = true })[1]

  if git_dir then
    -- .gitが見つかったら、その親ディレクトリ(プロジェクトルート)を取得
    local root = vim.fs.dirname(git_dir)
    return current_file:sub(#root + 2)
  else
    -- .gitが見つからない場合は通常の相対パスなどを返す（フォールバック）
    return vim.fn.expand('%:p:.')
  end
end

vim.api.nvim_create_user_command('CopyProjectRelativePath', function()
  vim.fn.setreg(vim.v.register, get_project_relative_path())
end, {})

keymap('n', '<Space>cl', '<cmd>CopyProjectRelativePath<cr>', { silent = true })

vim.api.nvim_create_user_command('CopyAbsolutePath', function()
  vim.fn.setreg(vim.v.register, vim.fn.expand('%:p'))
end, {})

keymap('n', '<Space>ca', '<cmd>CopyAbsolutePath<cr>')

-- タブ設定

keymap('n', '<S-l>', ':tabnext<CR>')
keymap('n', '<S-h>', ':tabprevious<CR>')
keymap('n', 'tt', ':tabnew<CR>')

-- telescope

local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
keymap('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
keymap('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- operator-stay-cursor-yankの挙動を再現

local cursor_pre_yank = nil

-- 1. y を押した瞬間のカーソル位置を記憶して、本来の 'y' を返す
vim.keymap.set({ "n", "x" }, "y", function()
  cursor_pre_yank = vim.api.nvim_win_get_cursor(0)
  return "y"
end, { expr = true, desc = "Yank without moving cursor" })

-- 2. ヤンク完了後 (TextYankPost) にカーソルを復元
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("yank_restore_cursor", { clear = true }),
  callback = function()
    -- オペレーターが 'y' で、かつ位置情報が保存されていれば復元
    if vim.v.event.operator == "y" and cursor_pre_yank then
      vim.api.nvim_win_set_cursor(0, cursor_pre_yank)
      cursor_pre_yank = nil -- リセット
    end
  end,
})
