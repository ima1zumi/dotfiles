vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function(ctx)
    -- 必要に応じて`ctx.match`に入っているファイルタイプの値に応じて挙動を制御
    -- `pcall`でエラーを無視することでパーサーやクエリがあるか気にしなくてすむ
    _G.debug_ctx = ctx
    pcall(vim.treesitter.start)
  end,
})
