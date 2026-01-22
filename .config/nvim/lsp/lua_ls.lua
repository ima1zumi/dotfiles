return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      diagnostics = {
        unusedLocalExclude = { '_*' }
      }
    }
  }
}
