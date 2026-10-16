-- nvim-treesitter ships "folds" queries that fold everything (if/for/while,
-- tables, argument lists, ...). This replaces those queries with ones that
-- only capture function-like nodes, so 'za', 'zM' and 'zR' only affect
-- functions.

-- nvim-ufo is used to draw the folds and make them look pretty.
-- Only the treesitter provider is used, so the ufo only uses
-- our custom rules. The indent fallback would fold if/for blocks
-- again, and the lsp provider folds whatever the server sends.

vim.o.foldmethod = "expr" -- Fold ranges come from an expression
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99 -- Open files with all folds unfolded
vim.o.foldlevel = 99 -- Keep folds open when ufo hands over ('foldmethod' becomes "manual")

-- Node types that are dropped even though their name looks function-ish.
local ignore = { "call", "type", "signature", "declarator", "preproc" }

-- Node types for languages where the guess below is wrong.
local overrides = {
  sql = { "create_function" },
  templ = { "component_declaration", "function_declaration", "method_declaration" },
}

-- Languages that keep the default nvim-treesitter folds (headings, code
-- blocks, list items). No functions to fold, so nothing is lost here.
local keep_default = { markdown = true }

-- Languages already handled, so we only inspect a parser once.
local handled_langs = {}

--- Builds a "folds" query for {lang} that only captures functions.
--- Returns nil if no parser is installed, "" if the grammar has no functions.
local function build_query(lang)
  local node_types = overrides[lang]

  if not node_types then
    local ok, info = pcall(vim.treesitter.language.inspect, lang)
    if not ok then return nil end

    node_types = {}
    for name, named in pairs(info.symbols) do
      if named and type(name) == "string" and (name:find("function") or name:find("method")) then
        local keep = true
        for _, word in ipairs(ignore) do
          if name:find(word) then
            keep = false
            break
          end
        end
        if keep then node_types[#node_types + 1] = name end
      end
    end
  end

  if #node_types == 0 then return "" end

  local patterns = {}
  for _, node_type in ipairs(node_types) do
    patterns[#patterns + 1] = ("(%s) @fold"):format(node_type)
  end
  return table.concat(patterns, "\n")
end

local function ensure(lang)
  if handled_langs[lang] or keep_default[lang] then return end

  local query = build_query(lang)
  if query == nil then return end

  -- An empty query disables folds for the language entirely.
  handled_langs[lang] = true
  vim.treesitter.query.set(lang, "folds", query)
end

-- Cover the languages that already have a parser, including those injected
-- into other files (go code inside templ files, and so on).
for _, file in ipairs(vim.api.nvim_get_runtime_file("parser/*", true)) do
  ensure(vim.fn.fnamemodify(file, ":t:r"))
end

-- Catch parsers installed during the session (:TSInstall) and filetypes that
-- map to a language we have not seen yet.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("folds", {}),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang then ensure(lang) end
  end,
})

-- nvim-ufo draws the folds above.
-- Only the treesitter provider is used, so the plugin only uses our custom
-- rules for folds. The indent fallback would fold if/for blocks
-- again, and the lsp provider folds whatever the server sends.
return {
  "kevinhwang91/nvim-ufo",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "kevinhwang91/promise-async" },
  config = function()
    local ufo = require("ufo")

    ufo.setup({
      provider_selector = function() return { "treesitter" } end,
      -- Append a line count to the folded line, README style.
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may be less than the 2nd argument
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    })

    -- ufo uses 'foldmethod' "manual", so the built-in zR/zM (which change
    -- 'foldlevel') are remapped to the ufo API.
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>fo", "za", opts) -- Toggle the fold of the function under the cursor
    vim.keymap.set("n", "<leader>fp", function() ufo.peekFoldedLinesUnderCursor() end, opts) -- Peek inside the folded function
    vim.keymap.set("n", "<leader>zm", ufo.closeAllFolds, opts) -- Fold every function in the file
    vim.keymap.set("n", "<leader>zr", ufo.openAllFolds, opts) -- Unfold every function in the file
  end,
}
