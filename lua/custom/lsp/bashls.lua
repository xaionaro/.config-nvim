-- Custom configuration for Bash language server (bash-language-server).
-- Prefer Mason-managed binary when available, otherwise fall back to system `bash-language-server`.
local M = {}

local function resolve_cmd()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/bash-language-server"
  if vim.loop.fs_stat(mason_bin) then
    return { mason_bin, "start" }
  end

  if vim.fn.executable("bash-language-server") == 1 then
    return { "bash-language-server", "start" }
  end

  vim.notify(
    [[bash-language-server not found. Install via :MasonInstall bash-language-server or add it to PATH.]],
    vim.log.levels.WARN
  )
  return { "bash-language-server", "start" }
end

M.cmd = resolve_cmd()
M.filetypes = { "sh", "bash" }
M.single_file_support = true

-- Use sync root discovery like other custom servers to avoid Neovim 0.11 startup issues.
M.root_dir = function(fname)
  return vim.fs.root(fname, { ".git", "package.json", "Makefile" })
end

return M
