-- Custom configuration for the qmlls (Qt QML Language Server) provided via Mason.
-- This configuration intentionally does NOT attempt any fallbacks — it uses the Mason
-- installed binary at stdpath("data")/mason/bin/qmlls.
local M = {}

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/qmlls"

-- Only enable qmlls if the Mason-managed binary exists. No fallbacks.
if vim.loop.fs_stat(mason_bin) then
  M.cmd = { mason_bin }
  M.filetypes = { "qml" }
  M.root_dir = function(fname)
    return vim.fs.root(fname, { ".git", "package.json", "CMakeLists.txt", "meson.build" })
  end
else
  vim.notify(
    "qmlls (QML Language Server) not found in Mason (mason/bin/qmlls). Not enabling QML LSP. Install with :MasonInstall qmlls",
    vim.log.levels.WARN
  )
  -- Signal to the caller that this server should not be enabled.
  M.disabled = true
end

return M
