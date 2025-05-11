return {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        unusedvariables = true,
      },
      semanticTokens = true,
      semanticTokenTypes = {
        number = true,
        string = true,
      },
      staticcheck = true,
    },
  },
}
