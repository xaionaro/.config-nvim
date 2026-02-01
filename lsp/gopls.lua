return {
  cmd = { 'gopls', 'serve' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_dir = require('lspconfig.util').root_pattern('go.work', 'go.mod', '.git'),
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
