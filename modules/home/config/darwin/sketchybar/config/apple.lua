local sbar = require("sketchybar")
local fromNix = require("from_nix")
local palette = fromNix.palette
local popup_toggle = "sketchybar --set $NAME popup.drawing=toggle"

local apple_logo = sbar.add("item", {
	padding_right = 15,
	click_script = popup_toggle,
	icon = {
		string = "󰀵",
		font = {
			family = fromNix.fonts.symbols,
			size = 16.0,
		},
		color = "0xff" .. palette.green,
	},
	label = { drawing = "off" },
	popup = { height = 35 },
})

local apple_prefs = sbar.add("item", {
	position = "popup." .. apple_logo.name,
	icon = "󰒓",
	label = "Preferences",
})

apple_prefs:subscribe("mouse.clicked", function(_)
	sbar.exec("open -a 'System Preferences'")
	apple_logo:set { popup = { drawing = false } }
end)
