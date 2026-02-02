require "nvchad.mappings"

-- Clear NvChad's default <C-c> mapping (copy whole file) to avoid conflict with buffer closing
pcall(vim.keymap.del, "n", "<C-c>")

local map = vim.keymap.set

map("n", "<C-p>", "<cmd>Telescope frecency<CR>", { desc = "Telescope Frecency" })
map("n", "<S-f>", "<cmd>Telescope live_grep<CR>", { desc = "Search by content (VS Code style)" })
