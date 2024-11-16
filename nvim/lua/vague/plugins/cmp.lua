return {
  "yioneko/nvim-cmp",
  branch = "perf",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lua",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind-nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()
    luasnip.config.setup({})

    cmp.setup({
      snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },

      -- formats cmp items, my formatting currently is,
      -- [LSP] cmp_item     Function
      formatting = {
        expandable_indicator = true,
        fields = { "menu", "abbr", "kind" },
        format = require("lspkind").cmp_format({
          menu = {
            nvim_lsp = "[LSP]",
            buffer = "[BUF]",
            luasnip = "[SNIP]",
            nvim_lua = "[LUA]",
            path = "[PATH]",
          },
          before = require("tailwind-tools.cmp").lspkind_format,
        }),
        -- format = function(entry, item)
        --   item.kind = (icons[item.kind] or "") .. item.kind
        --   item.menu = ({
        --     nvim_lsp = "[LSP]",
        --     buffer = "[BUF]",
        --     luasnip = "[SNIP]",
        --     path = "[PATH]",
        --   })[entry.source.name]
        --   return item
        -- end,
      },

      window = {
        completion = cmp.config.window.bordered(), -- add border to cmp window
        documentation = cmp.config.window.bordered(), -- show docs for cmp item if hovered
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(), -- goto next cmp item
        ["<C-p>"] = cmp.mapping.select_prev_item(), -- goto prev cmp item
        ["<C-d>"] = cmp.mapping.scroll_docs(-4), -- scroll doc window
        ["<C-f>"] = cmp.mapping.scroll_docs(4), -- scroll doc window
        ["<CR>"] = cmp.mapping.confirm({ -- confirm the cmp item selection
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })

    -- enables completion for searching in buffer
    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- enables completion for cmdline
    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}
