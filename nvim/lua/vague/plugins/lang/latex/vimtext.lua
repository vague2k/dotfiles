return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    local sysname = vim.loop.os_uname().sysname
    if sysname == "Darwin" then
      vim.g.vimtex_view_method = "skim"
      return
    end
    vim.g.vimtex_view_method = "zathura"
  end,
}
