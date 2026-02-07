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
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "/mnt/c/Program\\ Files/SumatraPDF/SumatraPDF.exe"
      vim.g.vimtex_view_general_options = "-forward-search @tex @line @pdf"
    end
  end,
}
