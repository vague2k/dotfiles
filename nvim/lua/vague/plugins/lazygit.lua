return {
  "kdheepak/lazygit.nvim",
  keys = { "<leader>gg" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local lazygit = require("lazygit")

    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>gg", lazygit.lazygit, opts)
  end,
}
