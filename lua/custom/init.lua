-- Modular customization entry point.
local M = {}

M.setup = function()
  vim.opt.whichwrap = ""

  local map = vim.keymap.set
  map("n", ";", ":", { desc = "CMD enter command mode" })
  map("i", "jk", "<ESC>")

  -- Move between windows using Shift + Arrow keys
  map("n", "<S-Left>", "<C-w>h", { desc = "Move to left window" })
  map("n", "<S-Right>", "<C-w>l", { desc = "Move to right window" })
  map("n", "<S-Up>", "<C-w>k", { desc = "Move to upper window" })
  map("n", "<S-Down>", "<C-w>j", { desc = "Move to lower window" })

  -- Highlights (Ensuring VS Code-ish feel and Semantic Token visibility)
  local function apply_highlights()
    -- VS Code-ish identifier colors
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#9CDCFE" })
    vim.api.nvim_set_hl(0, "@property", { fg = "#9CDCFE" })
    vim.api.nvim_set_hl(0, "@property.go", { fg = "#9CDCFE" })
    vim.api.nvim_set_hl(0, "@module", { fg = "#2EA990" })
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
    vim.api.nvim_set_hl(0, "@lsp.typemod.typeParameter.definition.go", { fg = "#9CDCFE" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.string.format.go", { fg = "#9CDCFE" })

    -- Avante UI fixes (removing black strips and matching NvChad style)
    vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "AvanteSidebarWinHorizontalSeparator", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "AvantePromptInputBorder", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { link = "Normal" })
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "BufEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
    callback = function()
      vim.schedule(apply_highlights)
    end,
  })
  apply_highlights()

  -- Auto-open Neo-tree and Avante on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("AutoOpenSidebars", { clear = true }),
    callback = function()
      -- Ensure plugins are loaded
      require("lazy").load { plugins = { "neo-tree.nvim", "avante.nvim" } }

      -- Pre-focus a real editor window so Avante attaches to the right buffer
      local wins = vim.api.nvim_list_wins()
      for _, win in ipairs(wins) do
        local bufnr = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) or ""
        if ft ~= "neo-tree" and not ft:match "avante" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end

      -- Open Avante sidebar (on the right)
      pcall(vim.cmd, "AvanteChat")

      -- Open Neo-tree (on the left)
      pcall(vim.cmd, "Neotree show")

      -- Ensure focus is back in the main window
      vim.schedule(function()
        local wins = vim.api.nvim_list_wins()
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            local bufnr = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) or ""
            if ft ~= "neo-tree" and not ft:match "avante" then
              vim.api.nvim_set_current_win(win)
              vim.cmd "stopinsert"
              return
            end
          end
        end
      end)
    end,
  })

  -- Auto-exit if only sidebars are left
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "WinClosed" }, {
    group = vim.api.nvim_create_augroup("AutoQuit", { clear = true }),
    callback = function()
      vim.schedule(function()
        local wins = vim.api.nvim_list_wins()
        local sidebar_fts = {
          ["neo-tree"] = true,
          ["qf"] = true,
          ["notify"] = true,
        }

        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            local bufnr = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) or ""
            local bt = vim.api.nvim_get_option_value("buftype", { buf = bufnr }) or ""

            -- If it's a normal editor window (not a sidebar and not avante), keep nvim open.
            -- We consider it an editor window if it has a filetype AND it's not a sidebar.
            -- Or if it's an empty buffer that is NOT in a sidebar window.
            if not sidebar_fts[ft] and not ft:match "avante" then
              -- If it's a normal buffer (bt == "") or a terminal/help that we want to keep, return.
              -- We only want to quit if ALL remaining windows are sidebars.
              if bt == "" or bt == "terminal" or bt == "help" then
                return
              end
            end
          end
        end
        -- If we are here, only sidebars or special windows are left.
        if #wins > 0 then
          vim.cmd "qa"
        end
      end)
    end,
  })
end

return M
