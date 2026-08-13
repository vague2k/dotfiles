return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "templ",
  },
  single_file_support = true,
  init_options = {
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayVariableTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
      },
    },
    javascript = {
      validate = {
        enable = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayVariableTypeHints = true,
      },
    },
  },
}
