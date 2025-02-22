return {
  "j-hui/fidget.nvim",
  event = "VeryLazy",
  config = function()
    require("fidget").setup({})

    -- Let's other plugins that use vim.notify to display message to use notify
    vim.notify = require("fidget").notify
  end,
}
