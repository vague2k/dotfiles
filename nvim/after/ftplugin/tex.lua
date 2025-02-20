vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.tex" },
  callback = function()
    vim.opt.colorcolumn = "80"
    vim.opt.textwidth = 80
    vim.cmd([[TSDisable incremental_selection]])
    vim.cmd([[TSDisable indent]])
  end,
})

vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.tex" },
  callback = function()
    vim.opt.colorcolumn = "120"
    vim.opt.textwidth = 120
    vim.cmd([[TSEnable incremental_selection]])
    vim.cmd([[TSEnable indent]])
  end,
})
