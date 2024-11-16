return {
  "nvim-neo-tree/neo-tree.nvim",
  event = "VeryLazy",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      hijack_netrw_behavior = "open_default",
      source_selector = {
        winbar = true,
        show_scrolled_off_parent_node = true,
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "git_status" },
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            "node_modules",
          },
        },
      },
      event_handlers = {
        -- removes disables "set number" in neotree window
        {
          event = "vim_buffer_enter",
          handler = function()
            if vim.bo.filetype == "neo-tree" then vim.cmd([[setlocal fillchars=eob:\ ]]) end
          end,
        },
      },
    })

    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>pv", ":Neotree toggle<CR>", opts)
    vim.keymap.set("n", "<leader>pf", ":Neotree focus filesystem<CR>", opts)
    vim.keymap.set("n", "<leader>pb", ":Neotree focus buffers<CR>", opts)
    vim.keymap.set("n", "<leader>pg", ":Neotree focus git_status<CR>", opts)
  end,
}
