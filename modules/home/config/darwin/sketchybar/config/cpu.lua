local sbar = require("sketchybar")
local fromNix = require("from_nix")
local palette = fromNix.palette

sbar.add("item", {
	position = "right",
	label = {
		string = "CPU",
		font = { size = 7.0 },
	},
	icon = { drawing = false },
	width = 0,
	padding_right = 15,
	y_offset = 6,
})

-- TODO: handle events
sbar.add("item", {
	position = "right",
	label = {
		string = "CPU",
		font = {
			size = 8.0,
			style = "Semibold",
		},
	},
	y_offset = -4,
	padding_right = 15,
	width = 55,
	icon = { drawing = false },
	update_freq = 2,
})

sbar.add("graph", {
	position = "right",
	width = 0,
	graph = {
		color = "0xff" .. palette.red,
		fill_color = palette.red,
	},
	label = { drawing = false },
	icon = { drawing = false },
	background = { height = 30, drawing = true, color = "0x00000000" },
}, 75)

sbar.add("graph", {
	position = "right",
	graph = { color = palette.blue },
	label = { drawing = false },
	icon = { drawing = false },
	background = { height = 30, drawing = true, color = "0x00000000" },
}, 75)
