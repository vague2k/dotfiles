return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    -- import mason and mason_lspconfig
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup()

    mason_lspconfig.setup({
      automatic_enable = true,
      -- servers for mason to install
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "gopls",
        "templ",
        "html",
        "ts_ls",
        "tailwindcss",
        "cssls",
        "astro",
        "sqls",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "stylua",
        "goimports",
        "gofumpt",
        "golangci-lint",
        "prettierd",
        "jq",
        "ruff",
        "sqruff",
      },
    })
  end,
}
