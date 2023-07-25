local nix = require("nix")
local wezterm = require("wezterm")
local act = wezterm.action

return {
	enable_wayland = nix.nvidia == false,
	front_end = nix.nvidia and "WebGpu" or "OpenGL",
	term = "wezterm",
	font = wezterm.font(nix.font.name),
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
	unix_domains = {
		{
			name = "charybdis-hack",
			socket_path = "~/charyb.socket",
			proxy_command = { "ssh", "-T", "-A", "charybdis", "~/.local/bin/wezterm", "cli", "proxy" },
			local_echo_threshold_ms = 50000,
		},
	},
	ssh_domains = {
		{
			name = "charybdis",
			remote_address = "charybdis",
			remote_wezterm_path = "~/.local/bin/wezterm",
		},
	},
}
