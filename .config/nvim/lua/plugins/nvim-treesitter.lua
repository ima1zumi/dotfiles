return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    require("nvim-treesitter").setup()
    require("nvim-treesitter").install({
      "c",
      "javascript",
      "json",
      "lua",
      "ruby",
      "rust",
      "sql",
      "terraform",
      "vim",
      "vue",
      "yaml"
    })
  end,
}
