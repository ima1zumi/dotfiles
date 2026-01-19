return {
  'kana/vim-operator-replace',
  dependencies = { "kana/vim-operator-user" },
  keys = {
    { "s", "<Plug>(operator-replace)", mode = { "n", "x" }, desc = "Operator Replace", remap = true },
  },
}

