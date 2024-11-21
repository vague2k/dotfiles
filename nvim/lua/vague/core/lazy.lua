-- make sure lazy is installed and add it to the rtp
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "vague.plugins" },
  { import = "vague.plugins.themes" },
  { import = "vague.plugins.lsp" },
  { import = "vague.plugins.lang.go" },
  { import = "vague.plugins.lang.css" },
  { import = "vague.plugins.lang.python" },
  { import = "vague.plugins.lang.markdown" },
}, {
  -- dir where local plugins are stored
  dev = { path = "~/Documents/GitHub" },
  -- how the Lazy ui looks
  ui = {
    backdrop = 100, -- backdrop opacity, 100 is transparent
    border = "rounded", -- rounded borders
    title = "Lazy.nvim", -- only applies when border is not "none"
    title_pos = "center", -- only applies when border is not "none"
  },
  --- make lazy stfu when changing plugin confs
  change_detection = {
    notify = false,
  },
  -- shit i don't want/need
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
