require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<C-p>", "<cmd>Telescope frecency<CR>", { desc = "Telescope Frecency" })
