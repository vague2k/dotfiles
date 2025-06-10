return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  keys = { "<leader>pv" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      window = { width = 64 },
      source_selector = {
        winbar = true,
        sources = { { source = "filesystem" } },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = { "node_modules", "tmp", ".git", "__pycache_" },
        },
      },
      event_handlers = {
        {
          event = "vim_buffer_enter",
          handler = function()
            -- removes disables "set number" in neotree window
            if vim.bo.filetype == "neo-tree" then vim.cmd([[setlocal fillchars=eob:\ ]]) end
          end,
        },
      },
    })

    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>pv", ":Neotree toggle<CR>", opts)
  end,
}
