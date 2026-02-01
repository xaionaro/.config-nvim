return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    opts = {},
    keys = {
      { "<leader>e", "<Cmd>Neotree toggle<CR>", desc = "Explorer (Neo-tree)" },
    },
  },
}
