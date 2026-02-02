-- Consolidated custom plugin configurations.
return {
  -- Core LSP Support (Required for default server configs)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- AI Assistant
  {
    "ThePrimeagen/99",
    lazy = false,
    keys = {
      {
        "<leader>ap",
        function()
          require("99").fill_in_function_prompt()
        end,
        mode = { "n", "v" },
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
        mode = { "n", "v" },
        desc = "99: stop all",
      },
    },
    config = function()
      local _99 = require "99"
      _99.setup {
        logger = {
          level = _99.DEBUG,
          path = "/tmp/" .. vim.fs.basename(vim.uv.cwd()) .. ".99.debug",
          print_on_error = true,
        },
        completion = { custom_rules = { "scratch/custom_rules/" }, source = "cmp" },
        md_files = { "AGENT.md" },
      }
    end,
  },

  -- Tabs / Bufferline
  {
    "romgrk/barbar.nvim",
    dependencies = { "lewis6991/gitsigns.nvim", "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
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

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        panel = { enabled = true, auto_refresh = true },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<S-CR>",
            accept_word = "<C-Right>",
            accept_line = "<C-Down>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      }
    end,
  },

  -- AI Assistant (Autonomous/YOLO)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "copilot",
      auto_suggestions_provider = "copilot",
      providers = {
        copilot = {
          model = "gpt-5-mini",
          extra_request_body = {
            max_tokens = 32768,
          },
        },
      },
      behaviour = {
        auto_suggestions = false, -- Using copilot.lua for suggestions
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = true, -- YOLO mode: Apply changes immediately
        support_paste_from_clipboard = false,
        auto_focus_sidebar = false, -- Prevent jumping to sidebar
      },
      windows = {
        position = "right", -- sidebar position
        width = 30, -- default % based on available width
        sidebar_header = {
          enabled = false, -- cleaner UI
        },
        ask = {
          floating = false, -- Open 'AvanteAsk' in the sidebar
          start_insert = true,
          border = "rounded",
          focus_on_apply = "ours",
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- Copilot Chat (Backup/Aggressive mode)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { { "nvim-lua/plenary.nvim", branch = "master" } },
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatStop",
      "CopilotChatPrompts",
      "CopilotChatModels",
      "CopilotChatSave",
      "CopilotChatLoad",
    },
    keys = {
      {
        "<leader>ccw",
        function()
          require("CopilotChat").toggle { window = { layout = "vertical", width = 0.25 } }
        end,
        mode = { "n", "x" },
        desc = "CopilotChat toggle (split)",
      },
      {
        "<leader>ccr",
        function()
          require("CopilotChat").reset()
        end,
        mode = { "n", "x" },
        desc = "CopilotChat reset",
      },
      {
        "<C-i>",
        function()
          local chat = require "CopilotChat"
          local mode = vim.fn.mode()
          local ctx = (mode == "v" or mode == "V" or mode == "\22") and "#selection " or "#buffer:active "
          vim.ui.input({ prompt = "CopilotChat (YOLO)> " }, function(input)
            if input and input ~= "" then
              chat.ask(
                ctx
                  .. "Execute this task immediately. Output only the final code blocks and assume I want them applied: "
                  .. input
              )
            end
          end)
        end,
        mode = { "n", "x" },
        desc = "CopilotChat YOLO inline",
      },
    },
    opts = {
      model = "gpt-5-mini",
      window = { layout = "vertical", width = 0.25 },
      auto_insert_mode = false,
      system_prompt = "You are an aggressive autonomous coding assistant. Do not explain, do not apologize. Provide direct, ready-to-use code blocks for the requested task. Your goal is to be a one-shot execution tool.",
    },
  },

  -- Disable Autopairs
  { "windwp/nvim-autopairs", enabled = false },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = function()
      return require "configs.conform"
    end,
    config = function(_, opts)
      require("conform").setup(opts)
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        require("conform").format { lsp_format = "fallback" }
      end, { desc = "Format (conform)" })
    end,
  },

  -- LSP support
  { "williamboman/mason.nvim", opts = { ensure_installed = { "lua_ls", "stylua", "prettier", "buf" } } },

  -- File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>e", "<Cmd>Neotree toggle<CR>", desc = "Explorer (Neo-tree)" } },
    opts = {
      window = { width = 25 },
      filesystem = { filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false } },
    },
  },

  -- Telescope Frecency (VS Code-like file jumping)
  {
    "nvim-telescope/telescope-frecency.nvim",
    lazy = false,
    opts = {
      default_workspace = "CWD",
      show_unindexed = true,
      db_safe_mode = false,
    },
    config = function(_, opts)
      require("frecency").setup(opts)
      require("telescope").load_extension "frecency"
    end,
    dependencies = { "nvim-telescope/telescope.nvim" },
  },

  -- Scrollbar indicators (VS Code-like)
  {
    "petertriho/nvim-scrollbar",
    dependencies = {
      {
        "kevinhwang91/nvim-hlslens",
        config = function()
          require("hlslens").setup { build_gi = false }
        end,
      },
      "lewis6991/gitsigns.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local scrollbar = require "scrollbar"
      local colors = require("base46").get_theme_tb "base_30"

      scrollbar.setup {
        show = true,
        handle = {
          text = " ",
          color = colors.grey,
          hide_if_all_visible = true,
        },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.red },
          Warn = { color = colors.yellow },
          Info = { color = colors.blue },
          Hint = { color = colors.purple },
          Misc = { color = colors.green },
        },
        handlers = {
          diagnostic = true,
          search = true,
          gitsigns = true,
        },
      }
    end,
  },
}
