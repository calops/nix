local nix = require("nix")
local wezterm = require("wezterm")
local act = wezterm.action

return {
	term = "wezterm",
	font = wezterm.font_with_fallback {
		nix.font.name,
		nix.font.symbols,
	},
	window_decorations = "RESIZE",
	enable_wayland = true,
	font_size = nix.font.size,
	freetype_load_target = nix.font.hinting,
	cell_width = nix.font.cell_width,
	line_height = nix.font.cell_height,
	underline_thickness = 2,
	underline_position = -2,
	enable_tab_bar = false,
	color_scheme = "Catppuccin Mocha",
	allow_square_glyphs_to_overflow_width = "Always",
	animation_fps = 30,
	cursor_blink_rate = 500,
	default_cursor_style = "BlinkingBlock",
	warn_about_missing_glyphs = false,
	window_padding = {
		left = 0,
		bottom = 0,
		top = 0,
		right = 0,
	},
	visual_bell = {
		fade_in_function = "Ease",
		fade_in_duration_ms = 150,
		fade_out_function = "Ease",
		fade_out_duration_ms = 150,
	},
	window_frame = {
		font = wezterm.font(nix.font.name),
	},
	keys = {
		{
			key = "Tab",
			mods = "CTRL",
			action = act.SendKey { key = "Tab", mods = "CTRL" },
		},
		{
			key = "Tab",
			mods = "CTRL|SHIFT",
			action = act.SendKey { key = "Tab", mods = "CTRL|SHIFT" },
		},
		{
			key = "Enter",
			mods = "ALT",
			action = act.SendKey { key = "Enter", mods = "ALT" },
		},
	},
}
