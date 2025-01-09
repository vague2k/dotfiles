return {
  "vague2k/vague.nvim",
  dev = true,
  config = function()
    require("vague").setup({
      style = {
        boolean = "bold",
        error = "bold",
        keyword_return = "italic",
        builtin_constants = "bold",
        builtin_types = "bold",
      },
    })
    vim.cmd.colorscheme("vague")
  end,
}
