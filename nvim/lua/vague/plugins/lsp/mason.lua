return {
  "jay-babu/mason-null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    require("mason-null-ls").setup({
      -- ensure these formatters are installed
      automatic_installation = true,
      ensure_installed = {
        "stylua",
        "biome",
        "prettier",
        "gofumpt",
        "jq",
      },
    })
  end,
}
