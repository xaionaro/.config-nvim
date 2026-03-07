return {
  filetypes = { "zig", "zir" },
  root_dir = function(fname)
    return vim.fs.root(fname, { "build.zig", "build.zig.zon", ".git" })
  end,
}
