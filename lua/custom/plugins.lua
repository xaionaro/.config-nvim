-- Consolidated custom plugin configurations.
return {
  -- Treesitter for advanced syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "markdown", "go", "cpp", "c" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter not installed: run :Lazy sync", vim.log.levels.WARN)
        return
      end

      configs.setup(opts)

      if opts.highlight and opts.highlight.enable then
        vim.api.nvim_create_autocmd("FileType", {
          callback = function()
            local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
            if pcall(vim.treesitter.get_parser, 0, lang) then
              vim.treesitter.start()
            end
          end,
        })
      end
    end,
  },

  -- Core LSP Support (Required for default server configs)

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- ISC DHCP syntax highlighting
  {
    "vim-scripts/dhcpd.vim",
    lazy = false,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "┃" },
        topdelete = { text = "┃" },
        changedelete = { text = "┃" },
      },
    },
  },

  -- Tabs / Bufferline
  {
    "romgrk/barbar.nvim",
    lazy = false,
    dependencies = { "lewis6991/gitsigns.nvim", "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      clickable = true,
    },
    keys = {
      { "<C-,>", "<Cmd>BufferPrevious<CR>", desc = "Prev buffer tab" },
      { "<C-.>", "<Cmd>BufferNext<CR>",     desc = "Next buffer tab" },
      { "<C-c>", "<Cmd>BufferClose<CR>",    desc = "Close buffer tab" },
      { "<C-1>", "<Cmd>BufferGoto 1<CR>",   silent = true,            desc = "Go to buffer 1" },
      { "<C-2>", "<Cmd>BufferGoto 2<CR>",   silent = true,            desc = "Go to buffer 2" },
      { "<C-3>", "<Cmd>BufferGoto 3<CR>",   silent = true,            desc = "Go to buffer 3" },
      { "<C-4>", "<Cmd>BufferGoto 4<CR>",   silent = true,            desc = "Go to buffer 4" },
      { "<C-5>", "<Cmd>BufferGoto 5<CR>",   silent = true,            desc = "Go to buffer 5" },
      { "<C-6>", "<Cmd>BufferGoto 6<CR>",   silent = true,            desc = "Go to buffer 6" },
      { "<C-7>", "<Cmd>BufferGoto 7<CR>",   silent = true,            desc = "Go to buffer 7" },
      { "<C-8>", "<Cmd>BufferGoto 8<CR>",   silent = true,            desc = "Go to buffer 8" },
      { "<C-9>", "<Cmd>BufferGoto 9<CR>",   silent = true,            desc = "Go to buffer 9" },
      { "<C-0>", "<Cmd>BufferGoto 10<CR>",  silent = true,            desc = "Go to buffer 10" },
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

  -- AI Assistant (Claude Code)
  {
    "coder/claudecode.nvim",
    lazy = false,
    dependencies = {
      "folke/snacks.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown" },
        },
        ft = { "markdown", "Avante", "copilot-chat" },
      },
    },
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.25,
      },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude Code" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",        desc = "Focus Claude Code" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",    desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>",  desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>",  desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",        desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",         mode = "v", desc = "Send selection to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file from tree",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",   desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",     desc = "Deny diff" },
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
      system_prompt =
      "You are an aggressive autonomous coding assistant. Do not explain, do not apologize. Provide direct, ready-to-use code blocks for the requested task. Your goal is to be a one-shot execution tool.",
    },
  },

  -- Disable Autopairs
  { "windwp/nvim-autopairs",   enabled = false },

  -- nvim-cmp completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require "configs.cmp"
    end,
  },

  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = function()
      return require "configs.conform_opts"
    end,
    config = function(_, opts)
      local conform = require "conform"
      conform.setup(opts)
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        conform.format { lsp_format = "fallback" }
      end, { desc = "Format (conform)" })

      -- Global auto-format on save: call conform.format for every BufWritePre.
      -- We wrap in pcall to avoid any runtime errors preventing writes.
      if opts and opts.format_on_save and opts.format_on_save.enabled then
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*",
          callback = function(event)
            local bufnr = event.buf or vim.api.nvim_get_current_buf()
            -- Don't attempt to format non-file buffers
            local bt = vim.api.nvim_buf_get_option(bufnr, "buftype")
            if bt ~= "" and bt ~= "acwrite" then
              return
            end
            pcall(function()
              require("conform").format { lsp_format = "fallback", bufnr = bufnr }
            end)
          end,
        })
      end
    end,
  },

  -- Mason core (installs language servers)
  { "williamboman/mason.nvim", lazy = false, opts = {} },

  -- Ensure common formatters/linters are installed via Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    -- Run after mason.nvim is available
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local ok, mti = pcall(require, "mason-tool-installer")
      if not ok then
        vim.notify("mason-tool-installer not available: ensure_installed skipped", vim.log.levels.WARN)
        return
      end

      mti.setup {
        ensure_installed = {
          -- formatters used by conform
          "shfmt",
          "prettier",
          "stylua",
          "black",
          "gofumpt",
          "rustfmt",
          "clang-format",
          "buf",
          "json-lsp",
        },
        run_on_start = true,
        auto_update = false,
      }
    end,
  },

  -- Mason LSP bridge: ensure a list of servers are installed
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      local ok, lspconfig = pcall(require, "configs.lspconfig")
      if not ok then
        vim.notify("configs.lspconfig not available: ensure_installed skipped", vim.log.levels.WARN)
        return
      end

      local ensure = {}
      for _, server in ipairs(lspconfig.servers) do
        local mason_name = lspconfig.mason_package_map[server]
        table.insert(ensure, mason_name or server)
      end

      local ok_ml, ml = pcall(require, "mason-lspconfig")
      if not ok_ml then
        vim.notify("mason-lspconfig not available: ensure_installed skipped", vim.log.levels.WARN)
        return
      end
      ml.setup { ensure_installed = ensure }
    end,
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>e", "<Cmd>NvimTreeToggle<CR>", desc = "Explorer (NvimTree)" } },
    opts = {
      view = {
        width = 25,
        side = "left",
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = false,
          },
        },
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
      git = {
        enable = true,
        ignore = false,
      },
      filesystem_watchers = {
        enable = true,
        debounce_delay = 100,
        max_events = 1000,
        ignore_dirs = {
          "node_modules",
          "dist",
          ".git",
          ".cache",
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      actions = {
        open_file = {
          quit_on_open = false,
        },
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end,
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

  -- Clickable scrollbar (Scrollview)
  {
    "dstein64/nvim-scrollview",
    lazy = false,
    config = function()
      require("scrollview").setup {
        current_only = false,
        excluded_filetypes = { "NvimTree", "terminal", "nofile" },
        always_show = true,
        visibility = "always",
        base = "left",
        column = 2,
        winblend = 70,
        winblend_gui = 70,
        zindex = 1,
        hover = true,
        signs_scrollbar_overlap = "over",
        signs_overflow = "right",
        signs_max_per_row = 2,
        signs_max_per_row_by_group = { gitsigns = 1, diagnostics = 1 },
        diagnostics_severities = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
      }
      -- Enable signs for diagnostics, search results, and git changes
      require("scrollview.contrib.gitsigns").setup {
        add_highlight = "ScrollViewGitSignsAdd",
        change_highlight = "ScrollViewGitSignsChange",
        delete_highlight = "ScrollViewGitSignsDelete",
        only_first_line = true,
      }
      -- Internal search and diagnostic signs are usually enabled via setup,
      -- but we can explicitly refresh them.
    end,
    dependencies = { "lewis6991/gitsigns.nvim" },
  },

  -- Search enhancements
  {
    "kevinhwang91/nvim-hlslens",
    event = "BufReadPost",
    config = function()
      require("hlslens").setup { build_gi = false }
    end,
  },

  -- Breadcrumbs / statusline helper
  {
    "utilyre/barbecue.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      {
        "SmiteshP/nvim-navic",
        config = function()
          local ok, navic = pcall(require, "nvim-navic")
          if not ok then
            return
          end
          navic.setup {}

          -- Attach navic to buffers when LSP attaches (if server supports documentSymbolProvider)
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.server_capabilities and client.server_capabilities.documentSymbolProvider then
                pcall(function()
                  navic.attach(client, args.buf)
                end)
              end
            end,
          })
        end,
      },
    },
    config = function()
      require("barbecue").setup {
        -- show file path and LSP breadcrumbs when available
        create_autocmd = false, -- we manage updates via navic / LspAttach above
      }
      -- Create lightweight autocommands to update barbecue on relevant events
      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "CursorHold", "LspAttach" }, {
        callback = function()
          pcall(require("barbecue.ui").update)
        end,
      })
    end,
  },
}
