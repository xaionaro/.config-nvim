require "nvchad.options"
require("custom").setup()

vim.opt.title = true
vim.opt.titlestring = "neovim - %t"

-- Auto-reload files when changed externally (VSCode-like behavior)
vim.opt.autoread = true

-- OSC 52 clipboard provider for SSH / headless sessions without xclip/xsel.
-- Copy works via terminal escape sequences; paste falls back to the unnamed
-- register (most terminals can't serve OSC 52 paste back over SSH).
if not vim.g.clipboard then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = function(lines)
        local data = table.concat(lines, "\n")
        local b64 = vim.base64.encode(data)
        io.stdout:write(("\027]52;c;%s\027\\"):format(b64))
      end,
      ["*"] = function(lines)
        local data = table.concat(lines, "\n")
        local b64 = vim.base64.encode(data)
        io.stdout:write(("\027]52;c;%s\027\\"):format(b64))
      end,
    },
    paste = {
      ["+"] = function()
        return { vim.fn.getreg '"' }
      end,
      ["*"] = function()
        return { vim.fn.getreg '"' }
      end,
    },
  }
end
