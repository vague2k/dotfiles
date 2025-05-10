return {
  "mason-org/mason.nvim",
  dependencies = {
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

    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

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
    require("lazydev").find_workspace(vim.api.nvim_get_current_buf())
  end,
}
