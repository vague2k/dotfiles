local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Normal mode
keymap("n", "<C-h>", "<C-w>h", opts) -- Navigate left window
keymap("n", "<C-j>", "<C-w>j", opts) -- Navigate down window
keymap("n", "<C-k>", "<C-w>k", opts) -- Navigate up window
keymap("n", "<C-l>", "<C-w>l", opts) -- Navigate right window
keymap("n", "<C-f>", ":silent !tmux neww tmux-sessionizer<CR>", opts) -- Start a new tmux session in a different terminal tab
keymap("n", "<leader>r", vim.lsp.buf.rename, opts) -- renames a reference
keymap("n", "gd", vim.lsp.buf.definition, opts) -- goto a definition
keymap("n", "<leader>d", vim.diagnostic.open_float, opts) -- display diagnostic information

-- Insert mode
keymap("i", "jk", "<ESC>", opts) -- Pressing "jk" in insert mode escapes quickly

-- Visual mode
keymap("v", "<", "<gv", opts) -- Stay in indent mode when using <
keymap("v", ">", ">gv", opts) -- Stay in indent mode when using >
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts) -- Move selected text down
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts) -- Move selected text up
keymap("v", "p", '"_dP', opts) -- Whatever is yanked stays persistent even if copied on top of another word
keymap("v", "<C-c>", '"+y', opts) -- Simulates ctrl+c in windows

-- custom functionality
keymap("n", "<leader><leader>m", function() -- hot reload local plugins using :Lazy reload
  local cwd = vim.fn.getcwd()
  local split_path = vim.fn.split(cwd, "/")
  local plugin_name = split_path[#split_path]
  vim.cmd("Lazy reload " .. plugin_name)
end, opts)
