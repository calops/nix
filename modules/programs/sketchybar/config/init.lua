local sbar = require("sketchybar")
local fromNix = require("from_nix")
local palette = fromNix.palette

sbar.begin_config()
sbar.hotload(true)

sbar.bar {
	height = 41,
	color = "0xdd" .. palette.base,
	shadow = "on",
	position = "top",
	sticky = "on",
	padding_right = 9,
	padding_left = 9,
	corner_radius = 9,
	y_offset = -9,
	margin = 9,
	blur_radius = 40,
	notch_width = 200,
	display = "main",
}

sbar.default {
	updates = "when_shown",
	icon = {
		font = {
			family = "Terminess Nerd Font",
			size = 14.0,
		},
		color = "0xff" .. palette.text,
		y_offset = -4,
	},
	label = {
		font = {
			family = fromNix.fonts.text,
			style = "Semibold",
			size = 13.0,
		},
		color = "0xff" .. palette.text,
		y_offset = -4,
	},
	background = {
		height = 26,
		corner_radius = 9,
		border_width = 2,
	},
	popup = {
		background = {
			border_width = 0,
			corner_radius = 9,
			color = "0xaa" .. palette.base,
			shadow = { drawing = true },
		},
		blur_radius = 20,
	},
	padding_left = 5,
	padding_right = 5,
}

require("apple")
require("focused")

require("date")
require("battery")
-- require("cpu")
-- require("memory")
require("volume")

sbar.end_config()
sbar.event_loop()
