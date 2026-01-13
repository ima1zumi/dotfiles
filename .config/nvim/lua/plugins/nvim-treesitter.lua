return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    require("nvim-treesitter").setup()
    require("nvim-treesitter").install({ 
      "c",
      "rust",
      "javascript",
      "json",
      "lua",
      "ruby",
      "terraform",
      "vim",
      "vue",
      "yaml"
    })
  end,
}
