local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

config.font = wezterm.font("IosevkaTerm Nerd Font Mono")
config.font_size = 14
config.initial_rows = 100
config.initial_cols = 220
config.window_padding = {
	left = 30,
	right = 30,
	top = 30,
	bottom = 30,
}

-- this is how you override a wezterm colorscheme, simple lua table overriding :)
local my_afterglow = wezterm.color.get_builtin_schemes()["Afterglow"]
my_afterglow.background = "#0e0e0e"
config.color_schemes = {
	["my_afterglow"] = my_afterglow,
}
config.color_scheme = "my_afterglow"

-- make terminal background slightly transparent and blurry if on macos
if io.popen("uname"):read("*l") == "Darwin" then
	config.window_background_opacity = 0.90
	config.macos_window_background_blur = 20
end

config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = action.SpawnCommandInNewTab({
			args = { "zsh", "-c", "tmux-sessionizer" },
		}),
	},
	{
		key = "a",
		mods = "ALT",
		action = action.SpawnCommandInNewTab({
			args = { "zsh", "-c", "tmux-attacher" },
		}),
	},
}

return config
