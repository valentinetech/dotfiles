-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
-- local config = wezterm.config_builder()
if wezterm.config_builder then
	config = wezterm.config_builder()
end
--- Pass through Ctrl+Shift combinations to Neovim
config.keys = {
	-- Disable Ctrl+s
	{ key = "s", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	-- Disable all Ctrl+Shift letter keys
	{ key = "a", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "b", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "d", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "e", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "f", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "g", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "h", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "i", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "j", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "k", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "l", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "m", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "n", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "o", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "p", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "q", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "r", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "s", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "u", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "x", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "y", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "z", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
}
--max fps
config.max_fps = 240
config.animation_fps = 240

-- This is where you actually apply your config choices
config.keys = {
	{ key = "s", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
}
-- Gruvbox Dark theme
config.color_scheme = "Gruvbox dark, medium (base16)"

config.font = wezterm.font("Zed Plex Mono")
config.font_size = 16

config.window_decorations = "RESIZE"
config.macos_window_background_blur = 10
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.enable_tab_bar = false

return config
