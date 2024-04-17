local sbar = require("sketchybar")
local fromNix = require("from_nix")
local palette = fromNix.palette

local battery = sbar.add("item", {
	position = "right",
	icon = {
		font = {
			style = "Regular",
			size = 19.0,
		},
	},
	label = {
		font = {
			style = "Regular",
			size = 12.0,
		},
	},
	update_freq = 120,
})

local battery_levels = {
	discharging = {
		["0"] = "󰂎",
		["1"] = "󰁺",
		["2"] = "󰁻",
		["3"] = "󰁼",
		["4"] = "󰁽",
		["5"] = "󰁾",
		["6"] = "󰁿",
		["7"] = "󰂀",
		["8"] = "󰂁",
		["9"] = "󰂂",
		["10"] = "󰁹",
	},
	charging = {
		["0"] = "󰢟",
		["1"] = "󰢜",
		["2"] = "󰂆",
		["3"] = "󰂇",
		["4"] = "󰂈",
		["5"] = "󰢝",
		["6"] = "󰂉",
		["7"] = "󰢞",
		["8"] = "󰂊",
		["9"] = "󰂋",
		["10"] = "󰂅",
	},
}

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "󰂑"
		local color = "0xff" .. palette.text
		local charging, levels = true, battery_levels.charging

		if string.find(batt_info, "discharging") then
			charging, levels = false, battery_levels.discharging
		end

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			local charge_level = (tonumber(charge) + 5) // 10
			icon = levels[tostring(charge_level)]

			if charge_level < 2 and not charging then
				color = "0xff" .. palette.red
			end
		end

		battery:set {
			icon = { string = icon, color = color },
			label = { string = charge .. "%" },
		}
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)
