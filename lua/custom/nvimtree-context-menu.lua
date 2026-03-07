-- Right-click context menu for nvim-tree, mimicking VS Code's file explorer.
local M = {}

function M.open()
  local api = require("nvim-tree.api")

  -- Move tree cursor to the right-clicked node
  local mouse = vim.fn.getmousepos()
  if mouse.line > 0 then
    pcall(vim.api.nvim_win_set_cursor, 0, { mouse.line, 0 })
  end

  local tree_win = vim.api.nvim_get_current_win()
  local node = api.tree.get_node_under_cursor()
  local title = node and (" " .. node.name .. " ") or ""

  -- Determine parent directory for "New Folder" based on the clicked node.
  local parent_dir
  if node then
    parent_dir = node.type == "directory" and node.absolute_path
      or vim.fn.fnamemodify(node.absolute_path, ":h")
  end

  local items = {
    { label = "Open", shortcuts = { "<CR>" }, action = api.node.open.edit },
    { label = "Open in Split", shortcuts = { "<C-x>" }, action = api.node.open.horizontal },
    { label = "Open in VSplit", shortcuts = { "<C-v>" }, action = api.node.open.vertical },
    { label = "Open in Tab", shortcuts = { "<C-t>" }, action = api.node.open.tab },
    { separator = true },
    { label = "Rename", shortcuts = { "r" }, action = api.fs.rename },
    { label = "Copy", shortcuts = { "c" }, action = api.fs.copy.node },
    { label = "Cut", shortcuts = { "x" }, action = api.fs.cut },
    { label = "Paste", shortcuts = { "p" }, action = api.fs.paste },
    { label = "Delete", shortcuts = { "d" }, action = api.fs.remove },
    { label = "Trash", shortcuts = { "D" }, action = api.fs.trash },
    { separator = true },
    { label = "Copy Filename", shortcuts = { "y" }, action = api.fs.copy.filename },
    { label = "Copy Relative Path", shortcuts = { "Y" }, action = api.fs.copy.relative_path },
    { label = "Copy Absolute Path", shortcuts = { "gy" }, action = api.fs.copy.absolute_path },
    { separator = true },
    { label = "New File", shortcuts = { "a" }, action = api.fs.create },
    {
      label = "New Folder",
      shortcuts = { "A" },
      action = function()
        if not parent_dir then return end
        vim.ui.input({ prompt = "Create folder: " }, function(name)
          if not name or name == "" then return end
          vim.fn.mkdir(parent_dir .. "/" .. name, "p")
          api.tree.reload()
        end)
      end,
    },
  }

  -- Build display lines with right-aligned shortcut hints.
  local lines = {}
  local actionable = {} -- line number -> items index
  local menu_width = 32

  for _, item in ipairs(items) do
    if not item.separator then
      local hint = item.shortcuts and item.shortcuts[1] or ""
      local needed = vim.fn.strdisplaywidth("  " .. item.label) + vim.fn.strdisplaywidth(hint) + 4
      if needed > menu_width then menu_width = needed end
    end
  end

  for i, item in ipairs(items) do
    if item.separator then
      table.insert(lines, " " .. string.rep("─", menu_width - 2) .. " ")
    else
      local hint = item.shortcuts and item.shortcuts[1] or ""
      local label = "  " .. item.label
      local pad = menu_width - vim.fn.strdisplaywidth(label) - vim.fn.strdisplaywidth(hint) - 2
      table.insert(lines, label .. string.rep(" ", pad) .. hint .. "  ")
      actionable[#lines] = i
    end
  end

  -- Scratch buffer with the menu content.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  -- Position at mouse, clamped to editor bounds.
  local row = mouse.screenrow - 1
  local col = mouse.screencol
  local menu_height = math.min(#lines, vim.o.lines - 4)
  if row + menu_height + 2 > vim.o.lines then
    row = vim.o.lines - menu_height - 3
  end
  if col + menu_width + 2 > vim.o.columns then
    col = vim.o.columns - menu_width - 3
  end
  row = math.max(0, row)
  col = math.max(0, col)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = menu_width,
    height = menu_height,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  vim.wo[win].cursorline = true
  vim.wo[win].winhighlight = "Normal:NormalFloat,CursorLine:PmenuSel"

  -- Place cursor on the first actionable line.
  for nr = 1, #lines do
    if actionable[nr] then
      vim.api.nvim_win_set_cursor(win, { nr, 0 })
      break
    end
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function execute(item_idx)
    local action = items[item_idx].action
    close()
    vim.schedule(function()
      if not vim.api.nvim_win_is_valid(tree_win) then return end
      vim.api.nvim_set_current_win(tree_win)
      if action then action() end
    end)
  end

  -- Navigate between actionable lines, skipping separators.
  local function move(dir)
    local pos = vim.api.nvim_win_get_cursor(win)[1]
    while true do
      pos = pos + dir
      if pos < 1 or pos > #lines then return end
      if actionable[pos] then
        vim.api.nvim_win_set_cursor(win, { pos, 0 })
        return
      end
    end
  end

  local map_opts = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set("n", "<Esc>", close, map_opts)
  vim.keymap.set("n", "q", close, map_opts)
  vim.keymap.set("n", "j", function() move(1) end, map_opts)
  vim.keymap.set("n", "k", function() move(-1) end, map_opts)
  vim.keymap.set("n", "<Down>", function() move(1) end, map_opts)
  vim.keymap.set("n", "<Up>", function() move(-1) end, map_opts)

  vim.keymap.set("n", "<CR>", function()
    local idx = actionable[vim.api.nvim_win_get_cursor(win)[1]]
    if idx then execute(idx) end
  end, map_opts)

  vim.keymap.set("n", "<LeftMouse>", function()
    local m = vim.fn.getmousepos()
    if m.winid == win and actionable[m.line] then
      execute(actionable[m.line])
    elseif m.winid ~= win then
      close()
    end
  end, map_opts)

  vim.keymap.set("n", "<RightMouse>", close, map_opts)

  -- Direct shortcut keys from the menu hints.
  for _, item_idx in pairs(actionable) do
    local item = items[item_idx]
    if item.shortcuts then
      for _, key in ipairs(item.shortcuts) do
        if key ~= "<CR>" then
          vim.keymap.set("n", key, function() execute(item_idx) end, map_opts)
        end
      end
    end
  end

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = close,
  })
end

return M
