return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  config = function()
    local oil = require("oil")
    oil.setup({
      view_options = {
        show_hidden = true,
      },
      float = {
        max_width = 0.3,
        win_options = {
          winblend = 3,
        },
      },
    })

    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>pv", oil.toggle_float, opts)
  end,
}
