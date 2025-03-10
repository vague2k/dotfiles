vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "@boolean",
      timeout = 150,
    })
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.opt.colorcolumn = "80"
    vim.opt.textwidth = 80
  end,
})
