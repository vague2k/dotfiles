return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v4.x",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "folke/lazydev.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local lsp_zero = require("lsp-zero")
    lsp_zero.on_attach(function(_, bufnr)
      local bufmap = function(keys, func) vim.keymap.set("n", keys, func, { buffer = bufnr }) end

      bufmap("<leader>r", vim.lsp.buf.rename) -- renames a reference
      bufmap("gd", vim.lsp.buf.definition) -- goto a definition
      bufmap("K", vim.lsp.buf.hover) -- display reference information
      bufmap("<leader>fd", ":Telescope diagnostics bufnr=0<CR>") -- open a list of diagnostics
      bufmap("<leader>d", vim.diagnostic.open_float) -- display diagnostic information
      bufmap("<leader>n", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end) -- toggle LSP inlay hints
    end)

    lsp_zero.extend_lspconfig({
      float_border = "rounded",
    })

    lsp_zero.setup()
    require("mason").setup({})
    require("mason-lspconfig").setup({ ---@diagnostic disable-line

      -- ensure these LSPs are installed
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "biome",
        "astro",
        "gopls",
        "cssls",
        "tailwindcss",
        "jsonls",
        "texlab",
        "bashls",
        "jsonls",
        "sqlls",
        "marksman",
        "dockerls",
        "yamlls",
      },

      -- handlers for specific languages
      handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
          require("lazydev").setup({ library = { "nvim-dap-ui" } }) ---@diagnostic disable-line
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
                hint = { enable = true },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,
        gopls = function()
          require("lspconfig").gopls.setup({
            settings = {
              gopls = {
                analyses = {
                  unusedparams = true,
                  unusedvariables = true,
                },
                semanticTokens = true,
                semanticTokenTypes = {
                  number = true,
                  string = true,
                },
                staticcheck = true,
              },
            },
          })
        end,
      },
    })
  end,
}
