return {
  {
    "vague2k/vague.nvim",
    dev = true,
    priority = 1000,
    config = function() vim.cmd("colorscheme vague") end,
  },
  { "ficcdaf/ashen.nvim" },
  {

    "wnkz/monoglow.nvim",
    config = function()
      require("monoglow").setup({
        -- Change the "glow" color
        on_colors = function(colors) colors.glow = "#18c784" end,
      })
    end,
  },
}
