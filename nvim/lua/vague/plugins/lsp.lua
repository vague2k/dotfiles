return {
  "neovim/nvim-lspconfig", -- provides sensible defaults for LSPs
  dependencies = {
    "mason-org/mason.nvim", -- manages LSPs and tells nvim where they're installed
    "mason-org/mason-lspconfig.nvim", -- bridges the gap between mason and nvim-lspconfig
    "folke/lazydev.nvim", -- faster lua_ls setup for nvim
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufmap = function(keys, func) vim.keymap.set("n", keys, func, { buffer = args.buf }) end

        bufmap("<leader>r", vim.lsp.buf.rename) -- renames a reference
        bufmap("gd", vim.lsp.buf.definition) -- goto a definition
        bufmap("K", vim.lsp.buf.hover) -- display reference information
        bufmap("<leader>fd", ":Telescope diagnostics bufnr=0<CR>") -- open a list of diagnostics
        bufmap("<leader>d", vim.diagnostic.open_float) -- display diagnostic information
        bufmap("<leader>n", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end) -- toggle LSP inlay hint
      end,
    })

    require("mason").setup({})
    require("mason-lspconfig").setup({
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
        lua_ls = function()
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
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

    require("lazydev").setup({ ---@diagnostic disable-line
      library = {
        "nvim-dap-ui",
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end,
}
