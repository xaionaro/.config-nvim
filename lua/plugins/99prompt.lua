return {
  "ThePrimeagen/99",
  keys = {
    {
      "<leader>ap",
      function()
        require("99").fill_in_function_prompt()
      end,
      mode = {"n", "v"},
      desc = "99: fill function (with prompt)",
    },
    {
      "<leader>af",
      function()
        require("99").fill_in_function()
      end,
      mode = "n",
      desc = "99: fill function",
    },
    {
      "<leader>av",
      function()
        require("99").visual()
      end,
      mode = "v",
      desc = "99: visual",
    },
    {
      "<leader>as",
      function()
        require("99").stop_all_requests()
      end,
      mode = {"n", "v"},
      desc = "99: stop all",
    },
  },

  config = function()
    local _99 = require "99"
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)

    _99.setup {
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },
      completion = {
        custom_rules = { "scratch/custom_rules/" },
        source = "cmp",
      },
      md_files = { "AGENT.md" },
    }
  end,
}
