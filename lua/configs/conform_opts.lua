local options = {
  -- Enable formatters for common filetypes. If a formatter binary isn't
  -- available, conform will fall back to LSP formatting (see format_on_save).
  formatters_by_ft = {
    lua = { "stylua" },
    proto = { "buf" },
    markdown = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    sh = { "shfmt" }, -- shell scripts
    bash = { "shfmt" }, -- explicit mapping for bash filetype
    python = { "black" },
    go = { "gofumpt" },
    rust = { "rustfmt" },
    c = { "clang_format" },
    cpp = { "clang_format" },
  },

  format_on_save = {
    -- Enable automatic formatting on save.
    enabled = true,
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
