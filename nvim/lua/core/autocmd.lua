-- highlight a selection when you yank it
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "@boolean",
      timeout = 150,
    })
  end,
})

-- puts a colorcolumn at col 80, as a guideline
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.md",
  callback = function()
    vim.opt.colorcolumn = "80"
    vim.opt.textwidth = 80
  end,
})
