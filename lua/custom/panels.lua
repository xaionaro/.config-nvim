-- Side panels (file tree on the left, opencode terminal on the right).
-- Panels stay closed until navigated to with <S-Left>/<S-Right>, and are
-- hidden again when navigation moves away from them. Hiding keeps the
-- buffer alive, so the tree expansion state and the terminal session
-- (scrollback + running job) survive.
local M = {}

local state_file = vim.fn.stdpath "state" .. "/sidebar_widths.json"
local min_width = 24

-- Widths captured when a panel is hidden; used to restore it on reopen and
-- to persist widths even when the panel is hidden at save time.
local remembered = {}

-- Hidden NvimTree buffer state. nvim-tree always creates a fresh buffer on
-- open, so to preserve tree state across hides we keep the buffer ourselves:
-- flip bufhidden to "hide" and rename it (avoiding the "NvimTree_<tab>" name
-- collision if nvim-tree opens a fresh buffer in between). On re-show,
-- view.open_in_win { hijack_current_buf = true } re-attaches nvim-tree to the
-- preserved buffer with full window state.
local hidden_tree_buf = nil

local function opencode_terminal()
  local ok, term = pcall(require, "custom.opencode_terminal")
  return ok and term or nil
end

local function get_ft(buf)
  return vim.api.nvim_get_option_value("filetype", { buf = buf })
end

local function tree_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and get_ft(vim.api.nvim_win_get_buf(win)) == "NvimTree" then
      return win
    end
  end
  return nil
end

local function win_of_buf(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end

local function has_win_direction(dir)
  return vim.fn.winnr(dir) ~= vim.fn.winnr()
end

local function default_width()
  return math.max(min_width, math.floor(vim.o.columns * 0.25))
end

local function normalize_width(width)
  if type(width) ~= "number" or width < min_width then
    return default_width()
  end
  return math.min(width, math.max(min_width, vim.o.columns - 30))
end

local function read_state()
  local f = io.open(state_file, "r")
  if not f then
    return {}
  end
  local ok, data = pcall(vim.json.decode, f:read "*a")
  f:close()
  if not ok or type(data) ~= "table" then
    return {}
  end
  return data
end

local function resolve_width(key)
  if remembered[key] then
    return normalize_width(remembered[key])
  end
  local state = read_state()
  local width = state[key]
  if type(width) ~= "number" and key == "opencode" then
    -- Legacy state keys from previous panel implementations.
    width = state.codex or state.claude
  end
  return normalize_width(width)
end

local function nvim_tree_view()
  local ok, view = pcall(require, "nvim-tree.view")
  if ok and type(view.open_in_win) == "function" then
    return view
  end
  return nil
end

local function tracked_tree_bufnr(view)
  if type(view.get_bufnr) ~= "function" then
    return nil
  end
  local ok, bufnr = pcall(view.get_bufnr)
  return ok and bufnr or nil
end

local function restore_hidden_tree(buf)
  local view = nvim_tree_view()
  -- Stale if nvim-tree created its own new buffer in the meantime.
  if not view or tracked_tree_bufnr(view) ~= buf then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    return false
  end
  vim.cmd "topleft vertical split"
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  -- Re-attaches nvim-tree to the preserved buffer: re-registers the window,
  -- reapplies buffer/window options and the NvimTree_<tab> buffer name.
  local ok = pcall(view.open_in_win, { winid = win, hijack_current_buf = true, resize = false })
  if not ok then
    pcall(vim.api.nvim_win_close, win, true)
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    return false
  end
  pcall(vim.api.nvim_win_set_width, win, resolve_width "nvimtree")
  vim.api.nvim_set_current_win(win)
  return true
end

local function show_tree()
  local win = tree_win()
  if win then
    vim.api.nvim_set_current_win(win)
    return
  end
  local buf = hidden_tree_buf
  hidden_tree_buf = nil
  if buf and vim.api.nvim_buf_is_valid(buf) and restore_hidden_tree(buf) then
    return
  end
  vim.cmd "NvimTreeOpen"
  win = tree_win()
  if not win then
    return
  end
  pcall(vim.api.nvim_win_set_width, win, resolve_width "nvimtree")
  vim.api.nvim_set_current_win(win)
end

local function show_opencode()
  local term = opencode_terminal()
  if not term then
    return
  end
  term.focus()
  local bufnr = term.get_active_terminal_bufnr()
  local win = bufnr and win_of_buf(bufnr)
  if win then
    pcall(vim.api.nvim_win_set_width, win, resolve_width "opencode")
  end
end

local function hide_win(key, win)
  if vim.api.nvim_win_is_valid(win) then
    remembered[key] = vim.api.nvim_win_get_width(win)
    pcall(vim.api.nvim_win_hide, win)
  end
end

local function hide_tree(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  remembered.nvimtree = vim.api.nvim_win_get_width(win)
  hidden_tree_buf = buf
  pcall(vim.api.nvim_set_option_value, "bufhidden", "hide", { buf = buf })
  pcall(vim.api.nvim_buf_set_name, buf, "NvimTree_hidden_" .. vim.api.nvim_get_current_tabpage())
  pcall(vim.api.nvim_win_hide, win)
end

function M.move_left()
  local buf = vim.api.nvim_get_current_buf()
  local term = opencode_terminal()
  local opencode_bufnr = term and term.get_active_terminal_bufnr() or nil

  -- Moving away from the opencode panel: land left, then hide it.
  if opencode_bufnr and buf == opencode_bufnr then
    if has_win_direction "h" then
      local win = vim.api.nvim_get_current_win()
      vim.cmd "wincmd h"
      hide_win("opencode", win)
    end
    return
  end

  -- Nothing left of the file tree.
  if get_ft(buf) == "NvimTree" then
    return
  end

  if has_win_direction "h" then
    vim.cmd "wincmd h"
    return
  end

  -- Left edge reached: open the file tree panel.
  show_tree()
end

function M.move_right()
  local buf = vim.api.nvim_get_current_buf()

  -- Moving away from the file tree: land right, then hide it.
  if get_ft(buf) == "NvimTree" then
    if has_win_direction "l" then
      local win = vim.api.nvim_get_current_win()
      vim.cmd "wincmd l"
      hide_tree(win)
    end
    return
  end

  local term = opencode_terminal()
  local opencode_bufnr = term and term.get_active_terminal_bufnr() or nil

  -- Nothing right of the opencode panel.
  if opencode_bufnr and buf == opencode_bufnr then
    return
  end

  if has_win_direction "l" then
    vim.cmd "wincmd l"
    return
  end

  -- Right edge reached: open the opencode panel.
  show_opencode()
end

local function has_editor_window()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = get_ft(buf)
      local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
      if ft ~= "NvimTree" and bt ~= "terminal" then
        return true
      end
    end
  end
  return false
end

local function save_widths()
  -- Skip when no editor windows are left, to avoid saving inflated widths
  -- after the main window closed and sidebars expanded.
  if not has_editor_window() then
    return
  end
  local widths = {}
  local twin = tree_win()
  if twin then
    widths.nvimtree = vim.api.nvim_win_get_width(twin)
  end
  local term = opencode_terminal()
  local opencode_bufnr = term and term.get_active_terminal_bufnr() or nil
  local owin = opencode_bufnr and win_of_buf(opencode_bufnr)
  if owin then
    local width = vim.api.nvim_win_get_width(owin)
    if width >= min_width then
      widths.opencode = width
    end
  end
  -- Panels hidden earlier this session keep their last width.
  for key, width in pairs(remembered) do
    if widths[key] == nil then
      widths[key] = width
    end
  end
  if not next(widths) then
    return
  end
  local f = io.open(state_file, "w")
  if f then
    f:write(vim.json.encode(widths))
    f:close()
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("SavePanelWidths", { clear = true }),
    callback = save_widths,
  })

  -- Also save on resize (debounced) so widths are captured during normal use.
  local resize_timer = vim.uv.new_timer()
  vim.api.nvim_create_autocmd("WinResized", {
    group = vim.api.nvim_create_augroup("SavePanelWidthsOnResize", { clear = true }),
    callback = function()
      resize_timer:stop()
      resize_timer:start(1000, 0, vim.schedule_wrap(save_widths))
    end,
  })
end

return M
