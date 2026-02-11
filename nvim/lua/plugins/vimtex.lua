return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    local sysname = vim.loop.os_uname().sysname
    if sysname == "Darwin" then
      vim.g.vimtex_view_method = "skim"
      return
    end
    if sysname == "Linux" and os.getenv("WSL_DISTRO_NAME") then
      vim.g.vimtex_view_method = "zathura_simple"
      vim.g.vimtex_view_forward_search_on_start = 1
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search -inverse-search @tex @line @pdf"
    end
  end,
}
