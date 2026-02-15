-- Bridge between NvChad defaults and custom LSP configurations.
-- This file leverages Neovim 0.11's native LSP API for a modular setup.
local nvlsp = require "nvchad.configs.lspconfig"
nvlsp.defaults()

-- Global overrides: prevent NvChad from disabling semantic tokens.
vim.lsp.config("*", {
  capabilities = nvlsp.capabilities,
  on_init = function(_) end,
  semantic_tokens = true,
})

local servers = { "html", "cssls", "gopls", "marksman", "qmlls", "bashls", "clangd", "jsonls" }

-- Export servers list for mason-lspconfig dynamic auto-install configuration.
-- Mapping from nvim-lspconfig names to Mason package names.
local mason_package_map = {
  html = "html-lsp",
  cssls = "css-lsp",
  bashls = "bash-language-server",
  lua_ls = "lua-language-server",
  gopls = "gopls",
  marksman = "marksman",
  qmlls = "qmlls",
  clangd = "clangd",
  jsonls = "json-lsp",
}

for _, name in ipairs(servers) do
  -- Load custom options from lua/custom/lsp/<name>.lua
  local ok, custom_opts = pcall(require, "custom.lsp." .. name)
  local opts = vim.tbl_extend("force", { single_file_support = true }, ok and custom_opts or {})

  -- Mandatory synchronous root discovery for gopls to prevent startup crashes.
  if name == "gopls" then
    opts.root_dir = function(fname) return vim.fs.root(fname, { "go.work", "go.mod", ".git" }) end
  end

  vim.lsp.config(name, opts)

  -- Robust attachment for Neovim 0.11
  -- This ensures servers reliably attach to buffers in the Neovim 0.11 environment.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = opts.filetypes or name,
    callback = function(ev)
      -- print("FileType autocmd triggered for " .. ev.match .. " buffer " .. ev.buf)
      local config = vim.lsp.config[name]
      if config then
        -- print("Starting LSP " .. name .. " for buffer " .. ev.buf)
        vim.lsp.start(config, { bufnr = ev.buf })
      else
        -- print("No config found for " .. name)
      end
    end,
  })
end

return {
  servers = servers,
  mason_package_map = mason_package_map,
}
