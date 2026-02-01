return {
  {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },

    -- Optional, but needed if you enable the `gitsigns` handler below
    dependencies = { "lewis6991/gitsigns.nvim" },

    config = function()
      require("satellite").setup({
        current_only = false,
        winblend = 0, -- 0 = opaque, more VS Code-like; default example uses 50
        zindex = 40,
        width = 2,
        excluded_filetypes = {
          "neo-tree",
          "TelescopePrompt",
          "lazy",
          "mason",
          "help",
        },

        handlers = {
          cursor = {
            enable = true,
            -- any number of symbols
            symbols = { "⎺", "⎻", "⎼", "⎽" },
          },
          search = {
            enable = true,
          },
          diagnostic = {
            enable = true,
            signs = { "-", "=", "≡" },
            min_severity = vim.diagnostic.severity.HINT,
          },
          gitsigns = {
            enable = true,
            -- can only be a single character (multibyte is ok)
            signs = {
              add = "│",
              change = "│",
              delete = "-",
            },
          },
          marks = {
            enable = true,
            show_builtins = false,
            key = "m",
          },
          quickfix = {
            signs = { "-", "=", "≡" },
          },
        },
      })
    end,
  },
}

