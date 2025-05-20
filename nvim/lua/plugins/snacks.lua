return {
  "folke/snacks.nvim",
  dev = true,
  event = "VeryLazy",
  config = function()
    local snacks = require("snacks")

    snacks.setup({
      lazygit = {},
      bigfile = { size = 1024 * 1024 },
      zen = {
        toggles = {
          dim = false,
        },
        win = {
          width = 100,
        },
      },
      indent = {
        indent = { enabled = false },
        animate = {
          duration = {
            step = 30,
            total = 200,
          },
        },
        chunk = {
          enabled = true,
          char = {
            corner_top = "╭",
            corner_bottom = "╰",
            arrow = ">",
          },
        },
      },
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

    vim.keymap.set("n", "<leader>ff", snacks.picker.files, opts) -- Find files
    vim.keymap.set("n", "<leader>fl", snacks.picker.help, opts) -- Find help
    vim.keymap.set("n", "<leader>fh", snacks.picker.highlights, opts) -- Find highlights
    vim.keymap.set("n", "<leader>fd", snacks.picker.diagnostics, opts) -- Find diagnostics
    vim.keymap.set("n", "<leader>fg", snacks.picker.grep, opts) -- Live grep
    vim.keymap.set("n", "<leader>gf", snacks.picker.git_diff, opts) -- pick through git diffs
    vim.keymap.set("n", "<leader>co", snacks.picker.colorschemes, opts) -- colorschemes
    vim.keymap.set("n", "<leader>to", function() snacks.picker.todo_comments() end, opts) -- Find Todo comments
    vim.keymap.set("n", "<leader>pp", ":lua Snacks.picker() <cr>", opts) -- opens a list of pickers to choose from
    vim.keymap.set("n", "<leader>zz", snacks.zen.zen, opts) -- zen mode
    vim.keymap.set("n", "<leader>gg", snacks.lazygit.open, opts)
  end,
}
