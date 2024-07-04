require("core.utils")

local cached_highlights = CachedDict:new(function(key)
	return vim.api.nvim_get_hl(0, { name = key, link = false }) ---@type MyHighlight
end)

---@alias MyColor string

---@class MyHighlight
---@field fg MyColor
---@field bg MyColor

local function format_color(color)
	if type(color) == "string" then
		return color
	elseif type(color) == "number" then
		return string.format("#%x", color)
	end

	return nil
end

---@param color MyColor
---@param amount number
---@param bg MyColor | nil
---@return MyColor
local function darken_color(color, amount, bg)
	return require("catppuccin.utils.colors").darken(format_color(color), amount, format_color(bg))
end

---@param color MyColor
---@param amount number
---@param bg MyColor | nil
---@return MyColor
local function lighten_color(color, amount, bg)
	return require("catppuccin.utils.colors").lighten(format_color(color), amount, format_color(bg))
end

---@return table<string, MyColor>
local function get_palette() return require("catppuccin.palettes").get_palette() end

---@param x number
---@return number
local function correct_channel(x) return 0.04045 < x and math.pow((x + 0.055) / 1.055, 2.4) or (x / 12.92) end

---@param x number
---@return number
local function correct_lightness(x)
	local k1, k2 = 0.206, 0.03
	local k3 = (1 + k1) / (1 + k2)

	return 0.5 * (k3 * x - k1 + math.sqrt((k3 * x - k1) ^ 2 + 4 * k2 * k3 * x))
end

---@param x number
---@return number
local function cuberoot(x) return math.pow(x, 0.333333) end

---@param background MyColor
---@return MyColor
local function compute_visible_foreground(background)
	local dec = tonumber(background, 16) or error("Invalid color: " .. background)
	local b = correct_channel(math.fmod(dec, 256) / 255)
	local g = correct_channel(math.fmod((dec - b) / 256, 256) / 255)
	local r = correct_channel(math.floor(dec / 65536) / 255)

	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	local l_, m_, s_ = cuberoot(l), cuberoot(m), cuberoot(s)
	local L = correct_lightness(0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_)

	return L < 0.5 and get_palette().text or get_palette().base
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function() cached_highlights:reset() end,
})

return {
	hl = cached_highlights,
	darken = darken_color,
	brighten = lighten_color,
	palette = get_palette,
	compute_visible_foreground = compute_visible_foreground,
}
