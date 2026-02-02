local function force()
  -- VS Code-ish identifier color
  vim.api.nvim_set_hl(0, "Identifier", { fg = "#9cdcfe" })
  vim.api.nvim_set_hl(0, "@property", { fg = "#9cdcfe" })
  vim.api.nvim_set_hl(0, "@property.go", { fg = "#9cdcfe" })
  vim.api.nvim_set_hl(0, "@variable.member.go", { fg = "#809090" })
  vim.api.nvim_set_hl(0, "@constant.builtin", { link = "@keyword" })
  vim.api.nvim_set_hl(0, "@module", { fg="#808080" })
  -- Ensure semantic tokens for packages/modules use the gray color
  vim.api.nvim_set_hl(0, "@lsp.type.namespace", { link = "@module" })
  vim.api.nvim_set_hl(0, "@lsp.type.module", { link = "@module" })
end

-- Apply repeatedly at points where base46/plugins typically re-apply highlights
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "BufEnter", "FileType" }, {
  callback = function()
    vim.schedule(force) -- run after whatever triggered the event
  end,
})

force()
