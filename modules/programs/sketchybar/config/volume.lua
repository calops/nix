local sbar = require("sketchybar")
local fromNix = require("from_nix")
local palette = fromNix.palette

local volume_slider = sbar.add("slider", 100, {
	position = "right",
	updates = true,
	label = { drawing = false },
	icon = { drawing = false },
	slider = {
		highlight_color = palette.blue,
		width = 0,
		background = {
			height = 6,
			corner_radius = 3,
			color = palette.surface0,
		},
		knob = {
			string = "-",
			drawing = false,
		},
	},
})

local volume_icon = sbar.add("item", {
	position = "right",
	icon = {
		string = "󰕾 ",
		width = 0,
		align = "left",
		color = palette.subtext0,
		font = {
			style = "Regular",
			size = 14.0,
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			style = "Regular",
			size = 14.0,
		},
	},
})

volume_slider:subscribe(
	"mouse.clicked",
	function(env) sbar.exec("osascript -e 'set volume output volume " .. env["PERCENTAGE"] .. "'") end
)

volume_slider:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = "󰝟 "
	if volume > 60 then
		icon = "󰕾 "
	elseif volume > 30 then
		icon = "󰖀 "
	elseif volume > 0 then
		icon = "󰕿 "
	end

	volume_icon:set { label = icon }
	volume_slider:set { slider = { percentage = volume } }
end)

local function animate_slider_width(width)
	sbar.animate("tanh", 30.0, function() volume_slider:set { slider = { width = width } } end)
end

volume_icon:subscribe("mouse.clicked", function()
	if tonumber(volume_slider:query().slider.width) > 0 then
		animate_slider_width(0)
	else
		animate_slider_width(100)
	end
end)
