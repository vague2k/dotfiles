vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.md", "*.tex" },
  callback = function()
    vim.opt.colorcolumn = "80"
    vim.opt.textwidth = 80
  end,
})

vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.md", "*.tex" },
  callback = function()
    vim.opt.colorcolumn = "120"
    vim.opt.textwidth = 120
  end,
})
