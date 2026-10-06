---@module "neominimap.config.meta"
return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  init = function()
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      float = {
        window_border = "none",
      },
    }
  end,
}
