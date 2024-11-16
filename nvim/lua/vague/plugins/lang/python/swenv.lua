return {
  "AckslD/swenv.nvim",
  ft = { "python" },
  config = function()
    local swenv = require("swenv.api")

    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>ee", swenv.pick_venv, opts) -- Find virtual python environments
  end,
}
