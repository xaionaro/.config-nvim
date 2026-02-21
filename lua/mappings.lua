require "nvchad.mappings"

-- Clear NvChad's default <C-c> mapping (copy whole file) to avoid conflict with buffer closing
pcall(vim.keymap.del, "n", "<C-c>")

local map = vim.keymap.set

map("n", "<C-p>", "<cmd>Telescope frecency<CR>", { desc = "Telescope Frecency" })
map("n", "<S-f>", "<cmd>Telescope live_grep<CR>", { desc = "Search by content (VS Code style)" })
map("n", "<C-LeftMouse>", function()
  local mouse = vim.fn.getmousepos()
  vim.api.nvim_win_set_cursor(0, { mouse.line, mouse.column - 1 })

  -- Try definition first
  vim.lsp.buf.definition()

  -- Schedule fallback to references after a short delay
  vim.defer_fn(function()
    -- Check if we're still on the same position (meaning no jump happened)
    local current_pos = vim.api.nvim_win_get_cursor(0)
    if current_pos[1] == mouse.line then
      -- Use Telescope for references (read-only picker)
      require("telescope.builtin").lsp_references()
    end
  end, 500)
end, { desc = "LSP Definition or References (mouse)" })

-- Map Ctrl-. to LSP code actions in normal and visual modes
map({ "n", "v" }, "<C-.>", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP Code Action" })
