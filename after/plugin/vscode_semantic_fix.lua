local function fix_ts_property()
  -- Pick what you want properties to look like.
  -- "Identifier" is usually closest to VS Code for enum-ish members.
  local link_to = "Identifier" -- try "Constant" or "Type" if you prefer

  vim.api.nvim_set_hl(0, "@property",    { link = link_to })
  vim.api.nvim_set_hl(0, "@property.go", { link = link_to })
end

vim.api.nvim_create_autocmd({ "ColorScheme" }, { callback = fix_ts_property })
fix_ts_property()

