return {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        unusedvariables = true,
        -- because i fucking hate warnings all over my screen
        ST1000 = false, -- Incorrect or missing package comment
        ST1020 = false, -- The documentation of an exported function should start with the function's name
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
