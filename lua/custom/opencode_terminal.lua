local M = {}

local active_terminal_bufnr
local did_setup = false

local function is_valid_terminal(bufnr)
  return bufnr
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "terminal"
end

local function get_terminal_win(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end

local function focus_window(win)
  vim.api.nvim_set_current_win(win)
  vim.cmd "startinsert"
end

local function terminal_width()
  return math.max(24, math.floor(vim.o.columns * 0.25))
end

local function set_terminal_window_options(win)
  pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = win })
end

local function clear_active_if(bufnr)
  if active_terminal_bufnr == bufnr then
    active_terminal_bufnr = nil
  end
end

local function close_terminal_resources(bufnr)
  if not bufnr then
    return
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end

  if vim.api.nvim_buf_is_valid(bufnr) then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end
end

local function executable_for(command)
  if type(command) == "table" then
    return command[1]
  end
  if type(command) == "string" then
    return command:match "^%s*(%S+)"
  end
  return nil
end

local function can_start(command)
  local executable = executable_for(command)
  return type(executable) == "string" and executable ~= "" and vim.fn.executable(executable) == 1
end

function M.get_active_terminal_bufnr()
  if is_valid_terminal(active_terminal_bufnr) then
    return active_terminal_bufnr
  end
  clear_active_if(active_terminal_bufnr)
  return nil
end

function M.close()
  local bufnr = M.get_active_terminal_bufnr()
  if not bufnr then
    return
  end

  close_terminal_resources(bufnr)
  clear_active_if(bufnr)
end

local function open_existing_terminal(bufnr)
  local win = get_terminal_win(bufnr)
  if win then
    focus_window(win)
    return bufnr
  end

  vim.cmd("botright vertical sbuffer " .. bufnr)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(win, terminal_width())
  set_terminal_window_options(win)
  focus_window(win)
  return bufnr
end

function M.open(command, opts)
  command = command or { "opencode" }
  opts = opts or {}

  local existing = M.get_active_terminal_bufnr()
  if existing and not opts.replace then
    return open_existing_terminal(existing)
  end

  if not can_start(command) then
    vim.notify("Unable to start opencode", vim.log.levels.ERROR)
    return nil
  end

  if existing and opts.replace then
    M.close()
  end

  vim.cmd "botright vertical new"
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(win, terminal_width())
  local bufnr = vim.api.nvim_get_current_buf()
  active_terminal_bufnr = bufnr
  set_terminal_window_options(win)

  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "opencode"

  local job_opts = {
    term = true,
    on_exit = function()
      vim.schedule(function()
        close_terminal_resources(bufnr)
        clear_active_if(bufnr)
      end)
    end,
  }
  local ok, job_id = pcall(vim.fn.jobstart, command, job_opts)
  if not ok or type(job_id) ~= "number" or job_id <= 0 then
    vim.notify("Unable to start opencode", vim.log.levels.ERROR)
    close_terminal_resources(bufnr)
    clear_active_if(bufnr)
    return nil
  end

  focus_window(win)
  return bufnr
end

function M.focus()
  local bufnr = M.get_active_terminal_bufnr()
  if bufnr then
    return open_existing_terminal(bufnr)
  end
  return M.open()
end

function M.continue()
  return M.open({ "opencode", "--continue" }, { replace = true })
end

function M.setup()
  if did_setup then
    return
  end
  did_setup = true

  vim.api.nvim_create_user_command("Opencode", function()
    M.open()
  end, { desc = "Open opencode terminal", force = true })

  vim.api.nvim_create_user_command("OpencodeFocus", function()
    M.focus()
  end, { desc = "Focus opencode terminal", force = true })

  vim.api.nvim_create_user_command("OpencodeContinue", function()
    M.continue()
  end, { desc = "Run opencode --continue", force = true })

  vim.api.nvim_create_user_command("OpencodeClose", function()
    M.close()
  end, { desc = "Close opencode terminal", force = true })
end

return M
