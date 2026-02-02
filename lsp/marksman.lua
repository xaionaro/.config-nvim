return {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'markdown.mdx' },
  -- Synchronous root discovery prevents the "assertion failed" crash in Neovim 0.11 startup
  root_dir = function(fname)
    return vim.fs.root(fname, { '.git', 'package.json' })
  end,
  init_options = { statusNotification = true },
}
