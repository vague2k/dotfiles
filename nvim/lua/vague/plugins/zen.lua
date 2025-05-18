return {
  "shortcuts/no-neck-pain.nvim",
  config = function()
    local nnp = require("no-neck-pain")
    nnp.setup({
      autocmds = { enableOnVimEnter = true },
      buffers = {
        colors = { blend = 0.3 },
        wo = { fillchars = "eob: " }, -- hides end of buffer characters
      },
      integrations = { snacks = { enabled = true } },
    })
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>zz", nnp.toggle, opts) -- distraction free coding
  end,
}
