return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "main",
  main = "nvim-treesitter",
  dependencies = {
    "virchau13/tree-sitter-astro",
  },
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
    local ensureInstalled = {
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
    }
    local alreadyInstalled = require("nvim-treesitter").get_installed()
    local parsersToInstall = vim
      .iter(ensureInstalled)
      :filter(function(parser) return not vim.tbl_contains(alreadyInstalled, parser) end)
      :totable()
    require("nvim-treesitter").install(parsersToInstall)
  end,
}
