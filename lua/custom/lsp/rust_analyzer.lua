return {
  filetypes = { "rust" },
  root_dir = function(fname)
    return vim.fs.root(fname, { "Cargo.toml", "rust-project.json", ".git" })
  end,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = { command = "clippy" },
      cargo = { allFeatures = true },
    },
  },
}
