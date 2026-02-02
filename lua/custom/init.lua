-- Modular customization entry point.
local M = {}

M.setup = function()
  vim.opt.whichwrap = ""

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
    vim.api.nvim_set_hl(0, "@module", { fg = "#808080" })
    -- VS Code-ish type color
    vim.api.nvim_set_hl(0, "Type", { fg = "#4EC9B0" })
    vim.api.nvim_set_hl(0, "@keyword", { fg = "#C586C0" })
    vim.api.nvim_set_hl(0, "@constant.builtin", { fg = "#569CD6" })
    vim.api.nvim_set_hl(0, "@type.builtin", { fg = "#569CD6" })
    vim.api.nvim_set_hl(0, "@type", { fg = "#4EC9B0" })
    -- VS Code-ish parameter color
    vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#9CDCFE" })
    -- Link Semantic Tokens to the gray @module highlight.
    -- This identifies package names (like 'fmt') specifically.
    vim.api.nvim_set_hl(0, "@lsp.type.namespace", { link = "@module" })
    vim.api.nvim_set_hl(0, "@lsp.type.module", { link = "@module" })
    vim.api.nvim_set_hl(0, "@lsp.type.namespace.go", { link = "@module" })
  end
  vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "BufEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
    callback = function()
      vim.schedule(apply_highlights)
    end,
  })
  apply_highlights()
end

return M
