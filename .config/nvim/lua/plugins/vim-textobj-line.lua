return {
  "kana/vim-textobj-line",
  dependencies = { "kana/vim-textobj-user" },
  keys = {
    { "il", mode = { "o", "x" }, desc = "Inner Line" },
    { "al", mode = { "o", "x" }, desc = "Around Line" },
  },
}
