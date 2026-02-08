-- Custom configuration for clangd (C++ LSP)
-- This file is loaded by lua/configs/lspconfig.lua

return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(fname)
    return vim.fs.root(fname, { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" })
  end,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
