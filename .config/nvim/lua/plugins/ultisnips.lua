-- to be honest im REALLY only using this for latex,
-- but i could use it in the future for some different types of snippets
return {
  "Sirver/ultisnips",
  ft = { "tex" },
  config = function()
    vim.g.UltiSnipsExpandTrigger = "<Tab>"
    vim.g.UltiSnipsJumpForwardTrigger = "<Tab>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"
  end,
}
