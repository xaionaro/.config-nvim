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

-- Set filetype to 'conf' for generic .conf files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  desc = "Set conf filetype for .conf files",
  pattern = "*.conf",
  callback = function(args)
    vim.bo[args.buf].filetype = "conf"
  end,
})

-- Auto-enter insert mode when focusing opencode input
-- Also auto-focus input when focusing output (logs)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  desc = "Opencode focus management",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "opencode" then
      vim.schedule(function()
        vim.cmd "startinsert!"
      end)
    elseif ft == "opencode_output" then
      -- If focusing output, find input window and focus it
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "opencode" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end
  end,
})
