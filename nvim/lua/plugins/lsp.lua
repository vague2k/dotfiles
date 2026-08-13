return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
    "folke/lazydev.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    require("lazydev").setup({ ---@diagnostic disable-line
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })

    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "E",
          [vim.diagnostic.severity.WARN] = "W",
          [vim.diagnostic.severity.HINT] = "H",
          [vim.diagnostic.severity.INFO] = "I",
        },
      },
      update_in_insert = false,
      virtual_text = false,
      underline = false,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = true,
      },
    })

    -- NOTE: All configured LSPs are enabled via `automatic_enable=true`
    --
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    vim.lsp.config("*", { capabilities = capabilities })
  end,
}
