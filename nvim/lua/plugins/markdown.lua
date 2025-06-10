return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- plugin already does it's own lazy loading
  config = function()
    require("markview").setup({
      preview = { icons = "devicons" },
    })
  end,
}
