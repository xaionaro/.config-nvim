require "nvchad.autocmds"

-- Auto-reload files when changed externally (VSCode-like behavior)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  desc = "Auto-reload files when changed externally",
  command = "if mode() != 'c' | checktime | endif",
})

-- Notify when file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  desc = "Notify when file is reloaded",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})
