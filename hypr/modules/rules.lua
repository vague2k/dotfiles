hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name = "suppress-maximize-events",
  match = { class = ".*" },

  suppress_event = "maximize",
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move = "20 monitor_h-120",
  float = true,
})

-- Battle.net launcher (opened from steam)
hl.window_rule({
  name = "battlenet-float",
  match = { title = "Battle.net" },
  float = true,
  size = { "(monitor_w*0.75)", "(monitor_h*0.80)" },
  center = true,
})

-- World of Warcraft (opened from bnet under steam proton)
--
-- Static window rules are evaluated before the
-- window exists, so this uses an event + dispatch instead.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.on("window.open", function(window)
  if window == nil then return end
  local title = (window.title or ""):lower()
  if title:match("world of warcraft") then
    hl.dispatch(hl.dsp.window.fullscreen({ action = "set", window = window }))
  end
end)
