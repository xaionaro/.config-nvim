-- Custom configuration for Marksman (Markdown language server).
local M = {}

-- Resolve marksman binary: prefer Mason-managed binary, fall back to system `marksman`.
local function resolve_marksman_cmd()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/marksman"
  if vim.loop.fs_stat(mason_bin) then
    return { mason_bin, "server" }
  end

  if vim.fn.executable("marksman") == 1 then
    return { "marksman", "server" }
  end

  -- Nothing found: notify once and still return the default so lsperror is clear to the user.
  vim.notify([[marksman executable not found. Install via :MasonInstall marksman or add marksman to PATH.]], vim.log.levels.WARN)
  return { "marksman", "server" }
end

M.cmd = resolve_marksman_cmd()
M.filetypes = { "markdown", "markdown.mdx" }
-- Synchronous root discovery prevents the "assertion failed" crash in Neovim 0.11 startup.
M.root_dir = function(fname)
  return vim.fs.root(fname, { ".git", "package.json" })
end
M.init_options = { statusNotification = true }

return M
