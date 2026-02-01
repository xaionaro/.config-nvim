return {
  -- Inline autocomplete ("ghost text") + accept-word/line controls
  {
    "zbirenbaum/copilot.lua",
    requires = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
    cmd = "Copilot",
    event = "InsertEnter",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          vim.defer_fn(function()
            pcall(vim.cmd, "Copilot status")
          end, 500) -- ms
        end,
      })
    end,
    config = function()
      require("copilot").setup({
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
      })
    end,
  },

  -- Inline chat (float) + Full chat (split)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
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

    -- Keymaps live here so they exist BEFORE the plugin is loaded, and will lazy-load on press.
    keys = {
      -- Your existing ones (kept)
      {
        "<leader>ccw",
        function()
          require("CopilotChat").toggle({ window = { layout = "vertical", width = 0.5 } })
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

      -- Common “standard” set (cc* prefix is very widely used in configs)
      {
        "<leader>ccx",
        function()
          require("CopilotChat").reset()
        end,
        mode = { "n", "x" },
        desc = "CopilotChat reset (alias)",
      },
      {
        "<leader>ccs",
        function()
          require("CopilotChat").stop()
        end,
        mode = { "n", "x" },
        desc = "CopilotChat stop",
      },
      {
        "<leader>ccp",
        function()
          require("CopilotChat").select_prompt()
        end,
        mode = { "n", "x" },
        desc = "CopilotChat prompt actions",
      },
      {
        "<leader>ccm",
        function()
          require("CopilotChat").select_model()
        end,
        mode = { "n", "x" },
        desc = "CopilotChat models",
      },

      -- Quick chat (buffer / selection) — pattern from the project wiki
      {
        "<leader>ccq",
        function()
          vim.ui.input({ prompt = "CopilotChat (buffer)> " }, function(input)
            if not input or input == "" then
              return
            end
            local chat = require("CopilotChat")
            chat.open({ window = { layout = "vertical", width = 0.5 } })
            chat.ask("#buffer:active " .. input)
          end)
        end,
        mode = "n",
        desc = "CopilotChat quick chat (buffer)",
      },
      {
        "<leader>ccq",
        function()
          vim.ui.input({ prompt = "CopilotChat (selection)> " }, function(input)
            if not input or input == "" then
              return
            end
            local chat = require("CopilotChat")
            chat.open({ window = { layout = "vertical", width = 0.5 } })
            chat.ask("#selection " .. input)
          end)
        end,
        mode = "x",
        desc = "CopilotChat quick chat (selection)",
      },

      -- Your inline float chat (kept)
      {
        "<C-i>",
        function()
          local chat = require("CopilotChat")
          local mode = vim.fn.mode()
          local ctx = (mode == "v" or mode == "V" or mode == "\22") and "#selection " or "#buffer:active "

          vim.ui.input({ prompt = "CopilotChat> " }, function(input)
            if not input or input == "" then
              return
            end
            chat.open({
              window = {
                layout = "float",
                width = 80,
                height = 20,
                border = "rounded",
                title = " AI Assistant",
                zindex = 100,
              },
            })
            chat.ask(ctx .. input)
          end)
        end,
        mode = { "n", "x" },
        desc = "CopilotChat inline (float)",
      },

      -- One-shot “prompt shortcuts” using built-in /PromptName tokens + resources (#buffer/#selection/#gitdiff)
      -- Prompts and resource syntax are in :help CopilotChat.
      {
        "<leader>cce",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Explain #buffer:active")
        end,
        mode = "n",
        desc = "CopilotChat explain (buffer)"
      },
      {
        "<leader>cce",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Explain #selection")
        end,
        mode = "x",
        desc = "CopilotChat explain (selection)"
      },

      {
        "<leader>ccu",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Review #buffer:active")
        end,
        mode = "n",
        desc = "CopilotChat review (buffer)"
      },
      {
        "<leader>ccr",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Review #selection")
        end,
        mode = "x",
        desc = "CopilotChat review (selection)"
      },

      {
        "<leader>ccf",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Fix #buffer:active")
        end,
        mode = "n",
        desc = "CopilotChat fix (buffer)"
      },
      {
        "<leader>ccf",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Fix #selection")
        end,
        mode = "x",
        desc = "CopilotChat fix (selection)"
      },

      {
        "<leader>cco",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Optimize #buffer:active")
        end,
        mode = "n",
        desc = "CopilotChat optimize (buffer)"
      },
      {
        "<leader>cco",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Optimize #selection")
        end,
        mode = "x",
        desc = "CopilotChat optimize (selection)"
      },

      {
        "<leader>ccd",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Docs #buffer:active")
        end,
        mode = "n",
        desc = "CopilotChat docs (buffer)"
      },
      {
        "<leader>ccd",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Docs #selection")
        end,
        mode = "x",
        desc = "CopilotChat docs (selection)"
      },

      {
        "<leader>cct",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Tests #buffer:active")
        end,
        mode = "n",
        desc = "CopilotChat tests (buffer)"
      },
      {
        "<leader>cct",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Tests #selection")
        end,
        mode = "x",
        desc = "CopilotChat tests (selection)"
      },

      -- Commit message from staged diff
      {
        "<leader>ccc",
        function()
          local c = require("CopilotChat"); c.open({ window = { layout = "vertical", width = 0.5 } }); c.ask(
            "/Commit #gitdiff:staged")
        end,
        mode = "n",
        desc = "CopilotChat commit (staged)"
      },
    },

    config = function()
      local chat = require("CopilotChat")
      chat.setup({
        window = { layout = "vertical", width = 0.5 },
        auto_insert_mode = true,
      })
    end,
  },
}

-- return {
--   "github/copilot.vim",
--
--   -- lazy-loading triggers
--   cmd = "Copilot",
--   event = "InsertEnter",
--
--   -- runs BEFORE the plugin is loaded (good for g: vars)
--   init = function()
--     -- If you use nvim-cmp or other completion, don't let Copilot steal <Tab>
--     vim.g.copilot_no_tab_map = true
--     vim.api.nvim_create_autocmd("User", {
--       pattern = "LazyDone",
--       once = true,
--       callback = function()
--         -- run after UI is responsive
--         vim.defer_fn(function()
--           pcall(vim.cmd, "Copilot status")
--         end, 30000) -- ms
--       end,
--     })
--   end,
--
--   config = function()
--     -- Minimal accept mapping (so you can keep <Tab> for nvim-cmp/snippets)
--     -- copilot#Accept() is part of copilot.vim; shown in nvim-cmp docs’ integration example. :contentReference[oaicite:0]{index=0}
--     vim.keymap.set("i", "<S-CR>", function()
--       return vim.fn["copilot#Accept"](vim.api.nvim_replace_termcodes("<CR>", true, true, true))
--     end, { expr = true, replace_keycodes = false, silent = true })
--   end,
-- }
