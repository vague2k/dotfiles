return {
  "vague2k/huez.nvim",
  dev = true,
  config = function()
    require("huez").setup({})
    vim.keymap.set("n", "<leader>co", "<cmd>Huez<CR>", { noremap = true, silent = true })
  end,
}
