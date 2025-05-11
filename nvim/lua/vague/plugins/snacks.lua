return {
  "folke/snacks.nvim",
  keys = { "<leader>pv", "<leader>ff" },
  config = function()
    local snacks = require("snacks")

    snacks.setup({
      explorer = {},
      lazygit = {},
      input = {
        icon = "::",
        win = {
          width = 35,
          relative = "cursor",
          row = -3, -- puts prompt on top of cursor
          col = 0,
        },
      },
      picker = {
        prompt = " :: ",
        sources = {
          explorer = {
            exclude = { ".node_modules*", ".DS_Store" },
            include = { ".*" },
          },
          files = {
            exclude = { ".node_modules*", ".DS_Store" },
            include = { ".git*", ".go*", ".config", ".local", ".cache" },
          },
          todo_comments = {
            exclude = { "*.ics" },
            include = {},
          },
        },
      },
    })

    local opts = { noremap = true, silent = true }

    -- file explorer
    vim.keymap.set("n", "<leader>pv", snacks.explorer.open, opts) -- Find files

    -- picker stuff
    vim.keymap.set("n", "<leader>ff", snacks.picker.files, opts) -- Find files
    vim.keymap.set("n", "<leader>fl", snacks.picker.help, opts) -- Find help
    vim.keymap.set("n", "<leader>fh", snacks.picker.highlights, opts) -- Find highlights
    vim.keymap.set("n", "<leader>fd", snacks.picker.diagnostics, opts) -- Find diagnostics
    vim.keymap.set("n", "<leader>fg", snacks.picker.grep, opts) -- Live grep
    vim.keymap.set("n", "<leader>co", snacks.picker.colorschemes, opts) -- Find help
    vim.keymap.set("n", "<leader>to", function() snacks.picker.todo_comments() end, opts) -- Find Todo comments
    vim.keymap.set("n", "<leader>pp", ":lua Snacks.picker() <cr>", opts) -- opens a list of pickers to choose from

    -- lazygit
    vim.keymap.set("n", "<leader>gg", snacks.lazygit.open, opts)
  end,
}
