require "nvchad.options"
require("custom").setup()

vim.opt.title = true
vim.opt.titlestring = "neovim - %t"

-- Auto-reload files when changed externally (VSCode-like behavior)
vim.opt.autoread = true
