return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  key = { "<leader>ff", "<leader>fh", "<leader>fg" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("telescope").setup({})

    local opts = { noremap = true, silent = true }
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, opts) -- Find files
    vim.keymap.set("n", "<leader>fb", builtin.buffers, opts) -- Find buffers
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts) -- Find help tags
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts) -- live grep
  end,
}
