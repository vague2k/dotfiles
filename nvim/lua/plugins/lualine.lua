return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependecies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },
  config = function()
    require("lualine").setup({
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        always_divide_middle = false,
        disabled_filetypes = {
          "neo-tree",
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
