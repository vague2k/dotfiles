vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "@boolean",
      timeout = 110,
    })
  end,
})
