require("modules.monitors")
require("modules.autostart")
require("modules.animations")
require("modules.keybinds")
require("modules.rules")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 1,

    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
    allow_tearing = false,

    layout = "dwindle",
  },

  decoration = {
    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },
  },

  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,

    sensitivity = -0.55, -- -1.0 - 1.0, 0 means no modification.
    accel_profile = "flat",
  },

  dwindle = {
    preserve_split = true, -- You probably want this
  },

  master = {
    new_status = "master",
  },

  scrolling = {
    fullscreen_on_one_column = true,
  },

  misc = {
    force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
  },
})
