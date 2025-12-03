return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "folke/lazydev.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.lsp.config("*", { capabilities = vim.lsp.protocol.make_client_capabilities() })
    require("mason").setup()
    require("mason-lspconfig").setup({ ---@diagnostic disable-line
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "gopls",
        "templ",
        "ts_ls",
        "astro",
      },
    })
    require("lazydev").setup({ ---@diagnostic disable-line
      library = {
        "nvim-dap-ui",
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end,
}
