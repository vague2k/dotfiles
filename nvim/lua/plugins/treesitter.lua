return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "virchau13/tree-sitter-astro",
  },
  -- branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter.install").compilers = { "clang", "gcc" }
    local treesitter = require("nvim-treesitter.configs")
    -- local treesitter = require("nvim-treesitter.config")
    ---@diagnostic disable-next-line
    treesitter.setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "python",
        "go",
        "templ",
        "sql",
        "bash",
        "markdown",
        "markdown_inline",
        "c_sharp",
      },
      highlight = { enable = true },
    })
  end,
}
