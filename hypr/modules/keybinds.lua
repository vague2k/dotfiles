local programs = function()
  local terminal = "ghostty"
  return {
    terminal = terminal,
    fileManager = "nautilus",
    menu = "noctalia msg panel-toggle launcher",
    browser = "brave",
  }
end
local programs = programs()

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/configuring/core/binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(programs.terminal))
hl.bind(
  mainMod .. " + F",
  hl.dsp.exec_cmd(programs.fileManager, {
    float = true,
    size = { "(monitor_w*0.70)", "(monitor_h*0.70)" },
    center = true,
  })
)
hl.bind(
  mainMod .. " + R",
  hl.dsp.exec_cmd(programs.menu, {
    float = true,
    size = { "(monitor_w*0.20)", "(monitor_h*0.40)" },
    center = true,
  })
)
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- noctalia
local noc_ipc = "noctalia msg "
hl.bind(mainMod .. "+ comma", hl.dsp.exec_cmd(noc_ipc .. "settings-toggle"))
hl.bind(mainMod .. "+ SHIFT + R", hl.dsp.exec_cmd(noc_ipc .. "config-reload"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(noc_ipc .. "window-switcher"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noc_ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noc_ipc .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noc_ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noc_ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noc_ipc .. "brightness-down"))
