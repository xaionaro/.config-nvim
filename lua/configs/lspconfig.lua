require("nvchad.configs.lspconfig").defaults()

-- Overriding NvChad's global on_init is required to prevent it from explicitly 
-- disabling semantic tokens during the LSP handshake.
vim.lsp.config("*", {
  on_init = function(_) end,
  semantic_tokens = true,
})

local servers = { "html", "cssls", "gopls", "marksman" }

-- Use the native Neovim 0.11 API to load and enable servers
for _, name in ipairs(servers) do
  local ok, opts = pcall(require, "lsp." .. name)
  if ok then
    vim.lsp.config(name, opts)
  end
end

vim.lsp.enable(servers)
