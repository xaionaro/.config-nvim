vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- Ensure Neovim can see system treesitter parsers (your lua.so is here)
do
  local sys_nvim = "/usr/lib/x86_64-linux-gnu/nvim"

  lazy_config.performance = lazy_config.performance or {}
  lazy_config.performance.rtp = lazy_config.performance.rtp or {}
  lazy_config.performance.rtp.paths = lazy_config.performance.rtp.paths or {}

  local paths = lazy_config.performance.rtp.paths
  local seen = false
  for _, p in ipairs(paths) do
    if p == sys_nvim then
      seen = true
      break
    end
  end
  if not seen then
    table.insert(paths, sys_nvim)
  end
end

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
