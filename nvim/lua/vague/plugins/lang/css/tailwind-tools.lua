return {
  "luckasRanarison/tailwind-tools.nvim",
  ft = { "jsx", "tsx", "js", "ts", "html", "astro", "mjs", "css" },
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
  },
  config = function()
    local tt = require("tailwind-tools")
    tt.setup({
      document_color = {
        kind = "background",
      },
      cmp = {
        highlight = "background",
      },
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.jsx", "*.tsx", "*.js", "*.ts", "*.html", "*.astro", "*.mjs", "*.css" },
      callback = function() vim.cmd("TailwindSort") end,
    })
  end,
}
