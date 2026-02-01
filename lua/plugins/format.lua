return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- run right before saving
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        proto = { "clang-format" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback", -- use LSP formatting only if no formatter is available
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- Optional: manual format keybind
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format({ lsp_format = "fallback" })
      end, { desc = "Format (conform)" })
    end,
  },
}
