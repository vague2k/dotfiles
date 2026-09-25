local programs = function()
  local terminal = "ghostty"
  return {
    terminal = terminal,
    fileManager = "nautilus",
    menu = "qs ipc call launcher toggle",
    browser = "brave",
  }
end
local programs = programs()

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(programs.terminal))
hl.bind(
  mainMod .. " + E",
  hl.dsp.exec_cmd(programs.fileManager, {
    float = true,
    size = { "(monitor_w*0.70)", "(monitor_h*0.70)" },
    center = true,
  })
)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(programs.menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(
  mainMod .. " + P",
  hl.dsp.exec_cmd('grim -o "$(hyprctl monitors -j | jq -r ".[] | select(.focused) | .name")" - | wl-copy')
)
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

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

-- quickshell
local ipc = "qs ipc call "
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(ipc .. "wallpaper toggle"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(ipc .. "audio toggle"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(ipc .. "bluetooth toggle"))

-- window switcher (hold Alt+Tab to cycle, release Alt to focus)
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "switcher next"), { repeating = true })
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(ipc .. "switcher prev"), { repeating = true })
hl.bind("ALT + ALT_L", hl.dsp.exec_cmd(ipc .. "switcher commit"), { release = true })
hl.bind("ALT + ALT_R", hl.dsp.exec_cmd(ipc .. "switcher commit"), { release = true })

-- notifications
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(ipc .. "notifications dismiss_all"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(ipc .. "notifications dnd_toggle"))

-- audio
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
