return {
  "nvim-neotest/neotest",
  Lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/nvim-nio",
    -- adapters start here
    "nvim-neotest/neotest-go",
  },
  config = function()
    require("neotest").setup({ ---@diagnostic disable-line
      adapters = {
        require("neotest-go"),
      },
    })
  end,
}
