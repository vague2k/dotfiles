return {
  filetypes = { "astro" },

  init_options = {
    typescript = {
      tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
    },
  },
}
