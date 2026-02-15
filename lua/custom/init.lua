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

  -- Interpret .txt files as markdown for highlighting and LSP features
  vim.filetype.add {
    extension = {
      txt = "markdown",
    },
  }

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
            (ft == "" or (ft ~= "NvimTree" and ft ~= "Opencode" and ft ~= "OpencodeInput" and ft ~= "toggleterm"))
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

    vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "#181818" })
    vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "#121212" })
    vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#f5a742" })
    vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", { fg = "#f5a742" })
    vim.api.nvim_set_hl(0, "NvimTreeGitModified", { fg = "#f5a742" })
    vim.api.nvim_set_hl(0, "NvimTreeGitModifiedIcon", { fg = "#f5a742" })

    -- ScrollView highlights (Clickable scrollbar)
    local colors = require("base46").get_theme_tb "base_30"
    vim.api.nvim_set_hl(0, "ScrollView", { bg = "#a0a0a0" })
    vim.api.nvim_set_hl(0, "ScrollViewTrack", { bg = "#252525" })

    -- ScrollView Sign Highlights (Matching VS Code style)
    vim.api.nvim_set_hl(0, "ScrollViewDiagnosticsError", { bg = colors.red })
    vim.api.nvim_set_hl(0, "ScrollViewDiagnosticsWarn", { bg = colors.yellow })
    vim.api.nvim_set_hl(0, "ScrollViewDiagnosticsInfo", { bg = colors.blue })
    vim.api.nvim_set_hl(0, "ScrollViewDiagnosticsHint", { bg = colors.purple })
    vim.api.nvim_set_hl(0, "ScrollViewSearch", { fg = colors.orange })
    vim.api.nvim_set_hl(0, "ScrollViewGitSignsAdd", { bg = colors.green })
    vim.api.nvim_set_hl(0, "ScrollViewGitSignsChange", { bg = colors.blue })
    vim.api.nvim_set_hl(0, "ScrollViewGitSignsDelete", { bg = colors.red })
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "BufEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
    callback = function()
      vim.schedule(apply_highlights)
    end,
  })
  apply_highlights()

  -- Auto-open NvimTree and Opencode on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("AutoOpenSidebars", { clear = true }),
    callback = function()
      -- Capture the main window before opening sidebars
      local main_win = vim.api.nvim_get_current_win()

      -- Ensure plugins are loaded (call via pcall to avoid noisy output and type issues)
      pcall(function()
        require("lazy").load { plugins = { "nvim-tree.lua", "opencode.nvim" } }
      end)
      -- Redraw to clear any transient messages so Neovim doesn't require an extra <Enter>
      pcall(function()
        vim.cmd "redraw"
      end)

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
      pcall(function()
        vim.cmd "Opencode"
      end)
      if vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_set_current_win(main_win)
      end

      -- Open NvimTree (on the left)
      pcall(function()
        vim.cmd "NvimTreeOpen"
      end)
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
          -- Only move focus if we land in a sidebar window (exactly 'NvimTree' or 'Opencode').
          -- Do NOT move focus if we land in an input field (like 'OpencodeInput').
          if ft == "NvimTree" or ft == "Opencode" then
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
          ["NvimTree"] = true,
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

  -- Restore last cursor position when reopening a file (skip special buffers)
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("RememberCursor", { clear = false }),
    callback = function()
      if vim.bo.buftype ~= "" then
        return
      end
      local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 }) or ""
      -- Skip sidebars, opencode inputs and quickfix-like buffers
      if ft == "NvimTree" or ft:lower():match "opencode" or ft == "qf" then
        return
      end
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lnum = mark[1]
      if lnum > 0 and lnum <= vim.api.nvim_buf_line_count(0) then
        pcall(vim.api.nvim_win_set_cursor, 0, { lnum, mark[2] })
      end
    end,
  })

  -- Ensure command-line commands entered while a sidebar is focused act on the
  -- main editor window. This reroutes ':' (and mapped ';') so that commands
  -- like `:q` will affect the main window (and exit nvim) instead of closing
  -- the sidebar. We avoid rerouting interactive inputs like Opencode's prompt
  -- and terminals.
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = vim.api.nvim_create_augroup("CmdlineFocusMain", { clear = true }),
    callback = function()
      local win = vim.api.nvim_get_current_win()
      if not vim.api.nvim_win_is_valid(win) then
        return
      end
      local bufnr = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr }) or ""

      -- Don't reroute interactive plugin inputs or terminals
      if ft == "OpencodeInput" or ft == "toggleterm" then
        return
      end

      -- If the commandline was opened from a sidebar (NvimTree / opencode / qf),
      -- move focus back to a normal editor window so the command acts there.
      if ft == "NvimTree" or ft == "qf" or ft:lower():match("opencode") then
        -- Do this synchronously so the command will operate on the main window.
        focus_main_window()
      end
    end,
  })
end

-- Install lazy.nvim reloader workaround to avoid blocking "Press ENTER" prompts.
-- This overrides `lazy.manage.reloader.reload` at runtime to show a one-line
-- notification and persist detailed change info to the lazy state file.
local function install_lazy_reloader_workaround()
  local ok, reloader = pcall(require, "lazy.manage.reloader")
  if not ok or not reloader or type(reloader.reload) ~= "function" then
    return
  end

  local core_ok, core_config = pcall(require, "lazy.core.config")
  if not core_ok then
    core_config = { options = {} }
  end

  -- Install global output wrappers that can be toggled during reloads.
  -- We wrap once here so asynchronous notifications printed later by lazy's
  -- reload process are also suppressed while we want them hidden. Guard the
  -- wrapping so reloading this file multiple times (or running this twice)
  -- doesn't reassign the same fields and avoids duplicate-field diagnostics.
  if not vim.g._custom_wrapped_output then
    local suppress_output = false
    local _out_write = vim.api.nvim_out_write
    local _err_writeln = vim.api.nvim_err_writeln
    local _echo = vim.api.nvim_echo
    vim.api.nvim_out_write = function(...)
      if suppress_output then
        return
      end
      return _out_write(...)
    end
    vim.api.nvim_err_writeln = function(...)
      if suppress_output then
        return
      end
      return _err_writeln(...)
    end
    vim.api.nvim_echo = function(...)
      if suppress_output then
        return
      end
      return _echo(...)
    end
    -- expose the suppress flag for the rest of this function via a local
    -- upvalue by attaching it to the module-global marker table so the
    -- reloader can toggle it without creating a new wrapper.
    vim.g._custom_wrapped_output = { suppress = suppress_output }
  end

  -- Only wrap reload once to avoid duplicate-field diagnostics and double
  -- wrapping when this file is sourced multiple times.
  if not reloader._custom_wrapped_reload then
    local orig_reload = reloader.reload
    -- Override lazy's Util.warn to avoid multi-line printing which triggers the
    -- "Press ENTER" pager. We keep a reference to the original for safety.
    local ok_util, Util = pcall(require, "lazy.util")
    if ok_util and Util and type(Util.warn) == "function" then
      local orig_warn = Util.warn
      Util.warn = function(msg, opts)
        pcall(function()
          -- Normalize message to string
          local text = type(msg) == "table" and table.concat(msg, "\n") or tostring(msg)
          -- Append full details to lazy state file for inspection
          local statefile = (core_config.options and core_config.options.state) or
              (vim.fn.stdpath("state") .. "/lazy/state.json")
          local fd = io.open(statefile, "a")
          if fd then
            fd:write("\n" .. text .. "\n")
            fd:close()
          end
          -- Show a concise, single-line notify (non-blocking)
          vim.schedule(function()
            pcall(vim.notify, (type(msg) == "table" and (msg[1] or "Config change") or text), vim.log.levels.INFO,
              { title = "lazy.nvim" })
          end)
        end)
      end
    end
    reloader.reload = function(changes)
      -- Suppress output while original reload runs. Use the wrappers above so
      -- any async printing spawned by lazy during reload is also suppressed.
      if vim.g._custom_wrapped_output then
        -- flip the suppress flag stored in the marker table
        vim.g._custom_wrapped_output.suppress = true
      end
      local ok2, err = pcall(orig_reload, changes)
      -- Keep suppression enabled for a short time so any async printing
      -- scheduled by lazy during reload is suppressed. Use a short deferred
      -- timeout to ensure the scheduled lazy.notify runs before we re-enable
      -- output. 30ms is conservative but still unnoticeable.
      pcall(vim.defer_fn, function()
        if vim.g._custom_wrapped_output then
          vim.g._custom_wrapped_output.suppress = false
        end
      end, 30)

      -- Schedule a safe, non-blocking notify and persist full details to state.
      -- We use vim.schedule to ensure this runs outside fast event contexts.
      vim.schedule(function()
        local n = 0
        if type(changes) == "table" then
          n = #changes
        end
        local summary = "Config change detected. Reloading... (" .. n .. " change" .. (n == 1 and "" or "s") .. ")"
        pcall(vim.notify, summary, vim.log.levels.INFO, { title = "lazy.nvim" })

        pcall(function()
          local statefile = (core_config.options and core_config.options.state) or
              (vim.fn.stdpath("state") .. "/lazy/state.json")
          local fd = io.open(statefile, "a")
          if not fd then
            return
          end
          fd:write("\n# Config Change Detected. Reloading...\n")
          for _, change in ipairs(changes or {}) do
            local what = tostring(change.what or "")
            local file = tostring(change.file or "")
            fd:write("- " .. what .. ": " .. vim.fn.fnamemodify(file, ":p:~:.") .. "\n")
          end
          fd:close()
        end)
      end)

      if not ok2 then
        error(err)
      end
    end
    reloader._custom_wrapped_reload = true
  end
end

pcall(install_lazy_reloader_workaround)
-- Try again after startup in case lazy is loaded later
vim.api.nvim_create_autocmd("VimEnter", { callback = function() pcall(install_lazy_reloader_workaround) end })

-- Ensure the user always sees a minimal notification when the plugins spec is saved.
-- This runs independently of lazy's internal reload logic so it will always show
-- a one-line message when `lua/custom/plugins.lua` is written.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "lua/custom/plugins.lua",
  callback = function()
    vim.schedule(function()
      local summary = "Config change detected: lua/custom/plugins.lua"
      pcall(vim.notify, summary, vim.log.levels.INFO, { title = "lazy.nvim" })
      pcall(vim.api.nvim_echo, { { summary } }, false, {})
      pcall(function()
        local ok, core = pcall(require, "lazy.core.config")
        local statefile = (ok and core and core.options and core.options.state) or
            (vim.fn.stdpath("state") .. "/lazy/state.json")
        local fd = io.open(statefile, "a")
        if fd then
          fd:write("\n# Config Change Detected (autocmd)\n- changed: lua/custom/plugins.lua\n")
          fd:close()
        end
      end)
    end)
  end,
})

return M
