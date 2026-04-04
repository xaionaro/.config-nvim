-- Custom configuration for clangd (C/C++ LSP).
-- Checks Mason bin, then system PATH. Disables if not found.
local M = {}

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/clangd"
local cmd_path

if vim.uv.fs_stat(mason_bin) then
  cmd_path = mason_bin
elseif vim.fn.executable("clangd") == 1 then
  cmd_path = "clangd"
end

if cmd_path then
  M.cmd = {
    cmd_path,
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  }
  M.filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }
  M.root_dir = function(fname)
    return vim.fs.root(fname, { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" })
  end
  M.init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  }
else
  vim.notify("clangd not found. Install clangd from apt or add to PATH.", vim.log.levels.WARN)
  M.disabled = true
end

return M
