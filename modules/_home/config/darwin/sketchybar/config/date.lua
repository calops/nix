local sbar = require("sketchybar")
local fromNix = require("from_nix")

local cal = sbar.add("item", {
	icon = {
		padding_right = 5,
		font = {
			family = fromNix.fonts.text,
			style = "Regular",
			size = 12.0,
		},
	},
	label = {
		width = 45,
		align = "right",
		font = {
			size = 16.0,
			style = "Semibold",
		},
	},
	position = "right",
	update_freq = 15,
})

local function update()
	local date = os.date("%a %d %b")
	local time = os.date("%H:%M")
	cal:set { icon = date, label = time }
end

cal:subscribe("routine", update)
cal:subscribe("forced", update)
