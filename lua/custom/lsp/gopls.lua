-- Custom configuration for gopls (Go language server).
return {
  -- Shared daemon keeps the workspace cache across nvim restarts; -remote.listen.timeout=24h
  -- keeps the daemon alive between sessions. Removing it silently erases the benefit:
  -- the daemon dies after 1 minute idle by default, with no error.
  cmd = { 'gopls', '-remote=auto', '-remote.listen.timeout=24h', 'serve' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  -- Synchronous root discovery prevents the "assertion failed" crash in Neovim 0.11 startup.
  -- This replaces the default async root_pattern which is incompatible with native setup.
  root_dir = function(fname)
    return vim.fs.root(fname, { 'go.work', 'go.mod', '.git' })
  end,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = false,
      analyses = { unusedparams = true },
      staticcheck = true,
      -- Explicitly enable semantic tokens for package name identification
      semanticTokens = true,
    },
  },
}
