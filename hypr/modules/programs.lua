---------------------
---- MY PROGRAMS ----
---------------------

-- Programs used throughout the configuration. Require this module wherever
-- you need one of them: local programs = require("modules.programs")

function programs()
  local terminal = "ghostty"
  return {
    terminal = terminal,
    fileManager = terminal .. " -e spf", -- superfile, TUI based
    menu = "hyprlauncher",
    browser = "brave",
  }
end

return programs()
