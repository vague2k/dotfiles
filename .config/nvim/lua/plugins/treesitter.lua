return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  dependencies = {
    "virchau13/tree-sitter-astro",
  },
  event = { "BufReadPre", "BufNewFile" },
  lazy = false,
  dependencies = {
    "virchau13/tree-sitter-astro",
  },
  config = function()
    local treesitter = require("nvim-treesitter")
    local ensure_installed = {
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
    treesitter.install(ensure_installed)

    -- attempts to get a treesitter parser for the current file's language
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then return end

        local ok_add = pcall(vim.treesitter.language.add, lang)
        if not ok_add then return end

        pcall(vim.treesitter.start, buf, lang)
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
