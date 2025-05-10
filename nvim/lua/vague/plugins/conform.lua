return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofumpt" },
        python = { "ruff" },
      },

      format_on_save = { -- builtin way to do "on LspAttach, format on save."
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      },
    })
  end,
}
