-- Custom configuration for gopls (Go language server).
-- Keep the daemon socket in this user's runtime directory. XDG_RUNTIME_DIR
-- can be inherited from a different login/session, but sharing that user's
-- runtime directory makes gopls dependent on its ACLs.
local runtime_dir = "/run/user/" .. vim.uv.getuid()
if vim.fn.isdirectory(runtime_dir) ~= 1 or vim.fn.filewritable(runtime_dir) ~= 2 then
  runtime_dir = vim.fn.stdpath("state") .. "/gopls-runtime"
  vim.fn.mkdir(runtime_dir, "p", 448) -- 0700
end

-- Keep the persistent analysis cache independent from the runtime socket.
local cache_home = vim.env.XDG_CACHE_HOME
if cache_home == nil or cache_home == "" then
  cache_home = vim.fn.expand("~/.cache")
end
local gopls_cache = vim.env.GOPLSCACHE
if gopls_cache == nil or gopls_cache == "" then
  gopls_cache = cache_home .. "/gopls"
end

return {
  -- Shared daemon keeps the workspace cache across nvim restarts; -remote.listen.timeout=24h
  -- keeps the daemon alive between sessions. Removing it silently erases the benefit:
  -- the daemon dies after 1 minute idle by default, with no error.
  cmd = { 'gopls', '-remote=auto', '-remote.listen.timeout=24h', 'serve' },
  cmd_env = {
    XDG_RUNTIME_DIR = runtime_dir,
    GOPLSCACHE = gopls_cache,
  },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  -- Synchronous root discovery prevents the "assertion failed" crash in Neovim 0.11 startup.
  -- This replaces the default async root_pattern which is incompatible with native setup.
  root_dir = function(fname)
    return vim.fs.root(fname, { 'go.work', 'go.mod', '.git' })
  end,
  settings = {
    gopls = {
      buildFlags = { "-tags=with_libav" },
      completeUnimported = true,
      usePlaceholders = false,
      analyses = { unusedparams = true },
      staticcheck = true,
      -- Explicitly enable semantic tokens for package name identification
      semanticTokens = true,
    },
  },
}
