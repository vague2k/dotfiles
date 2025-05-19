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
        "lua",
        "vim",
        "vimdoc",
        "python",
        "go",
        "sql",
        "bash",
        "markdown",
        "markdown_inline",
      },
    })
  end,
}
