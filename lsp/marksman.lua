return {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'markdown.mdx' },
  root_dir = vim.fs.root(0, { '.git', 'package.json' }),
  init_options = { statusNotification = true },
}
