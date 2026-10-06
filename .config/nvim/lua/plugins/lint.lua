return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("lint").linters_by_ft = {
      lua = { "luacheck" },
      python = { "ruff" },
      go = { "golangci-lint" },
    }
  end,
}
