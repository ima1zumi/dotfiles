return {
  "osyo-manga/vim-operator-stay-cursor",
  keys = {
    {
      "y",
      "<Plug>(operator-stay-cursor-yank)",
      mode = { "n", "x" },
      remap = true,
      desc = "Yank (Stay Cursor)",
    },
  },
}
