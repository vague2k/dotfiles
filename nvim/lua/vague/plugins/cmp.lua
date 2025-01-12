return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = "rafamadriz/friendly-snippets",
  version = "v0.9.2",
  config = function()
    require("blink-cmp").setup({
      keymap = {
        preset = "enter",
        cmdline = { preset = "default" },
      },
      -- completion menu behavior
      completion = {
        list = { selection = "auto_insert" }, -- inserts potential selection when scrolling through list
        documentation = {
          auto_show = true,
          window = {
            border = "rounded",
          },
        },
        menu = {
          border = "rounded",
          -- how the items are drawn (shown) in the menu, example below
          -- [LSP]  ctx.source_name  kind_icon  kind
          draw = {
            gap = 2,
            components = {
              source_name = {
                text = function(ctx)
                  if ctx.source_name == "LSP" then return "[LSP]" end
                  if ctx.source_name == "Snippets" then return "[SNIP]" end
                  if ctx.source_name == "Buffer" then return "[BUF]" end
                  if ctx.source_name == "Path" then return "[PATH]" end
                end,
              },
            },
            columns = {
              { "source_name", gap = 1 },
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", gap = 2 },
            },
          },
        },
      },
    })
  end,
}
