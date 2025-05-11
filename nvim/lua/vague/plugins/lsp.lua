return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "folke/lazydev.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufmap = function(keys, func) vim.keymap.set("n", keys, func, { buffer = args.buf }) end
        bufmap("<leader>r", vim.lsp.buf.rename) -- renames a reference
        bufmap("gd", vim.lsp.buf.definition) -- goto a definition
        bufmap("<leader>d", vim.diagnostic.open_float) -- display diagnostic information
      end,
    })
    vim.lsp.config("*", { capabilities = vim.lsp.protocol.make_client_capabilities() })
    require("mason").setup()
    require("mason-lspconfig").setup({ ---@diagnostic disable-line
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "gopls",
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
