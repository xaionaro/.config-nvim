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

-- Set filetype to 'conf' for all .conf files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  desc = "Set conf filetype for .conf files",
  pattern = "*.conf",
  callback = function(args)
    vim.bo[args.buf].filetype = "conf"
  end,
})

-- Override with dhcpd filetype for dhcp*.conf files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  desc = "Set dhcpd filetype for dhcp*.conf files",
  pattern = "dhcp*.conf",
  callback = function(args)
    vim.bo[args.buf].filetype = "dhcpd"
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

-- AI completion auto-import for Go files
-- When AI (copilot/99) completes, trigger gopls to add imports
local ai_import_timer = nil
vim.api.nvim_create_autocmd("CompleteDone", {
  desc = "Auto-add imports after AI completion in Go",
  callback = function(args)
    local cmp = require("cmp")
    local completion = args.completed_item

    if not completion or not completion.source then
      return
    end

    local source = completion.source.name
    if not source then
      return
    end

    local is_ai = source == "copilot" or source == "99"
    if not is_ai then
      return
    end

    local filetype = vim.bo.filetype
    if filetype ~= "go" and filetype ~= "gomod" and filetype ~= "gowork" and filetype ~= "gotmpl" then
      return
    end

    if ai_import_timer then
      vim.defer_fn.cancel(ai_import_timer)
    end

    ai_import_timer = vim.defer_fn(function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      for _, client in ipairs(clients) do
        if client.name == "gopls" then
          local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
          params.context = { only = { "source.organizeImports" } }
          client.request("textDocument/codeAction", params, function(err, result)
            if err or not result then
              return
            end
            if result[1] and result[1].edit then
              vim.lsp.util.apply_workspace_edit(result[1].edit)
            end
          end)
          break
        end
      end
    end, 500)
  end,
})

-- Auto-add imports on save for Go files
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Auto-add imports on save for Go files",
  pattern = { "*.go", "*.gomod", "*.gowork", "*.gotmpl" },
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == "gopls" then
        local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
        params.context = { only = { "source.organizeImports" } }
        client.request("textDocument/codeAction", params, function(err, result)
          if err or not result then
            return
          end
          if result[1] and result[1].edit then
            vim.lsp.util.apply_workspace_edit(result[1].edit)
          end
        end)
        break
      end
    end
  end,
})
