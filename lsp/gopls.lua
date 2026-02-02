return {
  cmd = { 'gopls', 'serve' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  -- Synchronous root discovery prevents the "assertion failed" crash in Neovim 0.11 startup
  root_dir = function(fname)
    return vim.fs.root(fname, { 'go.work', 'go.mod', '.git' })
  end,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = false,
      analyses = { unusedparams = true },
      staticcheck = true,
      semanticTokens = true,
    },
  },
}
