return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter.install").compilers = { "clang", "gcc" }
    local treesitter = require("nvim-treesitter.configs")
    ---@diagnostic disable-next-line
    treesitter.setup({
      ensure_installed = {
        "vim",
        "c_sharp",
        "vimdoc",
        "lua",
        "cpp",
        "python",
        "go",
        "tsx",
        "sql",
        "astro",
        "css",
        "regex",
        "bash",
        "markdown",
        "markdown_inline",
      },
    })
  end,
}
