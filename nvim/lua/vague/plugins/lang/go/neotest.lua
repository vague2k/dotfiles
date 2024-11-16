return {
  ft = { "go" },
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-go",
    "nvim-neotest/nvim-nio",
    -- Your other test adapters here
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-go"),
      },
    })
  end,
}
