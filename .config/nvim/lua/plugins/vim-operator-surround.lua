return {
  "rhysd/vim-operator-surround",
  dependencies = { "kana/vim-operator-user" },
  keys = {
    { "sa", "<Plug>(operator-surround-append)", mode = "n", desc = "Surround Append", remap = true },
    { "sd", "<Plug>(operator-surround-delete)", mode = "n", desc = "Surround Delete", remap = true },
    { "sr", "<Plug>(operator-surround-replace)", mode = "n", desc = "Surround Replace", remap = true },
  },
}
