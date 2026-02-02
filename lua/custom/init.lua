-- Modular customization entry point.
local M = {}

M.setup = function()
-- Options (Decoupled from NvChad defaults)
  vim.opt.whichwrap = ""

  -- Mappings (Decoupled from NvChad defaults)
  local map = vim.keymap.set
  map("n", ";", ":", { desc = "CMD enter command mode" })
  map("i", "jk", "<ESC>")

  -- Highlights (Ensuring VS Code-ish feel and Semantic Token visibility)
  local function apply_highlights()
    -- VS Code-ish identifier colors
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#9cdcfe" })
    vim.api.nvim_set_hl(0, "@property", { fg = "#9cdcfe" })
    vim.api.nvim_set_hl(0, "@property.go", { fg = "#9cdcfe" })
    vim.api.nvim_set_hl(0, "@variable.member.go", { fg = "#809090" })
    vim.api.nvim_set_hl(0, "@constant.builtin", { link = "@keyword" })
    vim.api.nvim_set_hl(0, "@module", { fg = "#808080" })
    -- Link Semantic Tokens to the gray @module highlight. 
    -- This identifies package names (like 'fmt') specifically.
    vim.api.nvim_set_hl(0, "@lsp.type.namespace", { link = "@module" })
    vim.api.nvim_set_hl(0, "@lsp.type.module", { link = "@module" })
    vim.api.nvim_set_hl(0, "@lsp.type.namespace.go", { link = "@module" })
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "BufEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
    callback = function() vim.schedule(apply_highlights) end,
  })
  apply_highlights()
end

return M
