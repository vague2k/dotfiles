return {
  "wnkz/monoglow.nvim",
  lazy = false,
  config = function()
    require("monoglow").setup({
      -- Change the "glow" color
      on_colors = function(colors) colors.glow = "#18c784" end,
    })
  end,
}
