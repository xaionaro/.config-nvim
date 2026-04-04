-- Custom configuration for the qmlls (Qt QML Language Server).
-- Uses the system-provided binary from qt6-declarative-dev-tools.
local M = {}

local candidates = {
  "/usr/lib/qt6/bin/qmlls",
  "/usr/bin/qmlls6",
}

local cmd_path
for _, path in ipairs(candidates) do
  if vim.uv.fs_stat(path) then
    cmd_path = path
    break
  end
end

if cmd_path then
  M.cmd = { cmd_path }
  M.filetypes = { "qml" }
  M.root_dir = function(fname)
    return vim.fs.root(fname, { ".git", "package.json", "CMakeLists.txt", "meson.build" })
  end
else
  vim.notify(
    "qmlls not found. Install qt6-declarative-dev-tools.",
    vim.log.levels.WARN
  )
  M.disabled = true
end

return M
