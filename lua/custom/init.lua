-- Modular customization entry point.
local M = {}

M.setup = function()
  vim.opt.whichwrap = ""

  local map = vim.keymap.set
  map("n", ";", ":", { desc = "CMD enter command mode" })
  map("i", "jk", "<ESC>")

  -- Move between windows using Shift + Arrow keys
  map({ "n", "i", "v", "t" }, "<S-Left>", "<C-\\><C-N><C-w>h", { desc = "Move to left window" })
  map({ "n", "i", "v", "t" }, "<S-Right>", "<C-\\><C-N><C-w>l", { desc = "Move to right window" })
  map({ "n", "i", "v", "t" }, "<S-Up>", "<C-\\><C-N><C-w>k", { desc = "Move to upper window" })
  map({ "n", "i", "v", "t" }, "<S-Down>", "<C-\\><C-N><C-w>j", { desc = "Move to lower window" })

  map({ "n", "v" }, "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })

  -- Highlights (Ensuring VS Code-ish feel and Semantic Token visibility)
  local function focus_main_window()
    local wins = vim.api.nvim_list_wins()
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    local current_ft = vim.api.nvim_get_option_value("filetype", { buf = current_buf }) or ""

    -- If we are already in an interactive/input field, don't move focus
    if current_ft == "OpencodeInput" or current_ft == "toggleterm" then
      return true
    end

    -- Try to find a window with a real file first
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_is_valid(win) then
        local bufnr = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) or ""
        local bt = vim.api.nvim_get_option_value("buftype", { buf = bufnr }) or ""
        -- Main window: not a sidebar, not Opencode, not a terminal, and is a normal file (bt == "")
        -- We allow ft == "" because a new empty buffer has no filetype yet.
        if
          (ft == "" or (ft ~= "neo-tree" and ft ~= "Opencode" and ft ~= "OpencodeInput" and ft ~= "toggleterm"))
          and bt == ""
        then
          vim.api.nvim_set_current_win(win)
          vim.cmd "stopinsert"
          return true
        end
      end
    end
    return false
  end

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

    -- Opencode UI fixes (removing black strips and matching NvChad style)
    vim.api.nvim_set_hl(0, "OpencodeSidebarWinSeparator", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "OpencodeSidebarWinHorizontalSeparator", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "OpencodePromptInputBorder", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "OpencodeSidebarNormal", { link = "Normal" })
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "BufEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
    callback = function()
      vim.schedule(apply_highlights)
    end,
  })
  apply_highlights()

  -- Auto-open Neo-tree and Opencode on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("AutoOpenSidebars", { clear = true }),
    callback = function()
      -- Capture the main window before opening sidebars
      local main_win = vim.api.nvim_get_current_win()

      -- Ensure plugins are loaded
      require("lazy").load { plugins = { "neo-tree.nvim", "opencode.nvim" } }

      -- Monkeypatch Opencode Sidebar to respect the focus setting synchronously
      local ok_sidebar, Sidebar = pcall(require, "opencode.sidebar")
      if ok_sidebar and Sidebar.open then
        local old_open = Sidebar.open
        Sidebar.open = function(self, opts)
          local ret = old_open(self, opts)
          local Config = require "opencode.config"
          if not Config.behaviour.auto_focus_sidebar then
            if self.code and self.code.winid and vim.api.nvim_win_is_valid(self.code.winid) then
              vim.api.nvim_set_current_win(self.code.winid)
            elseif vim.api.nvim_win_is_valid(main_win) then
              vim.api.nvim_set_current_win(main_win)
            end
          end
          return ret
        end
      end

      -- Open Opencode sidebar (on the right)
      pcall(vim.cmd, "Opencode")
      if vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_set_current_win(main_win)
      end

      -- Open Neo-tree (on the left)
      pcall(vim.cmd, "Neotree show")
      if vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_set_current_win(main_win)
      end

      -- Ensure focus is back in the main window as a final non-racy fallback
      vim.schedule(function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(main_win) then
            vim.api.nvim_set_current_win(main_win)
            vim.cmd "stopinsert"
          else
            focus_main_window()
          end
        end)
      end)
    end,
  })

  -- Ensure main window focus when terminal closes
  vim.api.nvim_create_autocmd("TermClose", {
    group = vim.api.nvim_create_augroup("TerminalFocus", { clear = true }),
    callback = function()
      -- Removed to avoid unexpected focus jumps
    end,
  })

  -- Ensure focus doesn't land on sidebars when a window is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    group = vim.api.nvim_create_augroup("WinClosedFocus", { clear = true }),
    callback = function()
      vim.schedule(function()
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_is_valid(win) then
          local bufnr = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) or ""
          -- Only move focus if we land in a sidebar window (exactly 'neo-tree' or 'Opencode').
          -- Do NOT move focus if we land in an input field (like 'OpencodeInput').
          if ft == "neo-tree" or ft == "Opencode" then
            focus_main_window()
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

            -- If it's a normal editor window (not a sidebar and not opencode), keep nvim open.
            -- We consider it an editor window if it has a filetype AND it's not a sidebar.
            -- Or if it's an empty buffer that is NOT in a sidebar window.
            if not sidebar_fts[ft] and not ft:lower():match "opencode" then
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
