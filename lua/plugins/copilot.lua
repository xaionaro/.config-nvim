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
    },
    config = function()
      local chat = require("CopilotChat")

      -- Default: "full chat window" as a vertical split
      chat.setup({
        window = { layout = "vertical", width = 0.5 },
        auto_insert_mode = true,
      })

      -- Inline chat: open a float and ask about #selection (visual) or #buffer:active (normal)
      local function inline_chat()
        local mode = vim.fn.mode()
        local resource = (mode == "v" or mode == "V" or mode == "\22") and "#selection " or "#buffer:active "

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
          chat.ask(resource .. input)
        end)
      end

      vim.keymap.set({ "n", "v" }, "<M-i>", inline_chat, { desc = "CopilotChat inline (float)" })
      vim.keymap.set("n", "<leader>cc", function()
        chat.toggle({ window = { layout = "vertical", width = 0.5 } })
      end, { desc = "CopilotChat toggle (split)" })

      vim.keymap.set("n", "<leader>cR", chat.reset, { desc = "CopilotChat reset" })
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
