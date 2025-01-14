vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.md", "*.tex" },
  callback = function(ev)
    vim.opt.colorcolumn = "80"
    vim.opt.textwidth = 80

    -- disable treesitter in .tex files so vimtex can do it's job
    local ext = ev.match:match("^.+(%..+)$")
    if ext == ".tex" then
      vim.cmd([[TSDisable incremental_selection]])
      vim.cmd([[TSDisable indent]])
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.md", "*.tex" },
  callback = function(ev)
    vim.opt.colorcolumn = "120"
    vim.opt.textwidth = 120

    -- reenable ts if file is .tex
    local ext = ev.match:match("^.+(%..+)$")
    if ext == ".tex" then
      vim.cmd([[TSEnable incremental_selection]])
      vim.cmd([[TSEnable indent]])
    end
  end,
})
