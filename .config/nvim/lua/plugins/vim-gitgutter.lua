return {
  'airblade/vim-gitgutter',
  keys = {
    { "<leader>gn", "<Plug>(GitGutterNextHunk)", mode = { "n" }, desc = "GitGutter: Next hunk", remap = true },
    { "<leader>gN", "<Plug>(GitGutterPrevHunk)", mode = { "n" }, desc = "GitGutter: Prev hunk", remap = true },
  },
}

