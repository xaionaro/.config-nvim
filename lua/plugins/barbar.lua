return {
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",     -- optional
      "nvim-tree/nvim-web-devicons", -- optional (icons)
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {},
    keys = {
      { "<C-,>", "<Cmd>BufferPrevious<CR>", desc = "Prev buffer tab" },
      { "<C-.>", "<Cmd>BufferNext<CR>", desc = "Next buffer tab" },
      { "<C-c>", "<Cmd>BufferClose<CR>", desc = "Close buffer tab" },
      { "<C-1>", "<Cmd>BufferGoto 1<CR>", silent = true, desc = "Go to buffer 1" },
      { "<C-2>", "<Cmd>BufferGoto 2<CR>", silent = true, desc = "Go to buffer 2" },
      { "<C-3>", "<Cmd>BufferGoto 3<CR>", silent = true, desc = "Go to buffer 3" },
      { "<C-4>", "<Cmd>BufferGoto 4<CR>", silent = true, desc = "Go to buffer 4" },
      { "<C-5>", "<Cmd>BufferGoto 5<CR>", silent = true, desc = "Go to buffer 5" },
      { "<C-6>", "<Cmd>BufferGoto 6<CR>", silent = true, desc = "Go to buffer 6" },
      { "<C-7>", "<Cmd>BufferGoto 7<CR>", silent = true, desc = "Go to buffer 7" },
      { "<C-8>", "<Cmd>BufferGoto 8<CR>", silent = true, desc = "Go to buffer 8" },
      { "<C-9>", "<Cmd>BufferGoto 9<CR>", silent = true, desc = "Go to buffer 9" },
      { "<C-0>", "<Cmd>BufferGoto 10<CR>", silent = true, desc = "Go to buffer 10" },
    },
  },
}
