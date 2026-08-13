return {
  filetypes = { "css", "scss", "less" },
  init_options = { provideFormatter = true },
  single_file_support = true,
  settings = {
    css = {
      lint = {
        unknownAtRules = "ignore",
      },
      validate = true,
    },
    scss = {
      lint = {
        unknownAtRules = "ignore",
      },
      validate = true,
    },
    less = {
      lint = {
        unknownAtRules = "ignore",
      },
      validate = true,
    },
  },
}
