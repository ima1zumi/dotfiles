-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins.mini-icons" }, -- アイコン
    { import = "plugins.oil" }, -- ファイラ
    { import = "plugins.neogit" }, -- git操作
    { import = "plugins.nvim-treesitter" }, -- treesitter
    { import = "plugins.telescope" }, -- Fuzzy Finder
    { import = "plugins.indent-blankline" }, -- インデント表示
    { import = "plugins.lualine" }, -- ステータスライン
    { import = "plugins.mini-trailspace" }, -- 末尾の空白表示/Trimコマンド
    { import = "plugins.ansi" }, -- ANSI Escape sequenceの表示
    { import = "plugins.file-line" }, -- file:lineで開く
    { import = "plugins.vim-operator-user" }, -- vim-operator-replaceなどの依存
    { import = "plugins.vim-operator-replace" },
    { import = "plugins.vim-operator-surround" },
    { import = "plugins.vim-textobj-user" },
    { import = "plugins.vim-textobj-line" }, -- sil
    { import = "plugins.vim-operator-stay-cursor" },
    -- No need to setting
    { "vim-jp/vimdoc-ja" },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
