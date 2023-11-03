local module = {}

module._colors_data = nil
function module.colors()
	if not module._colors_data then
		module._colors_data = {
			normal = module.get_hl("Normal"),
		}
	end
	return module._colors_data
end

function module.get_hl(name)
	return vim.api.nvim_get_hl(0, { name = name, link = false })
end

module._git_data = nil
function module.git()
	if not module._git_data then
		module._git_data = {
			add = {
				colors = module.get_hl("GitSignsAdd"),
				sign = vim.fn.sign_getdefined("GitSignsAdd")[1].text,
			},
			change = {
				colors = module.get_hl("GitSignsChange"),
				sign = vim.fn.sign_getdefined("GitSignsChange")[1].text,
			},
			delete = {
				colors = module.get_hl("GitSignsDelete"),
				sign = vim.fn.sign_getdefined("GitSignsDelete")[1].text,
			},
		}
	end
	return module._git_data
end

module._diags_data = nil
function module.diags()
	if not module._diags_data then
		module._diags_data = {
			error = {
				severity = 1,
				colors = module.get_hl("DiagnosticVirtualTextError"),
				sign = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
			},
			warn = {
				severity = 2,
				colors = module.get_hl("DiagnosticVirtualTextWarn"),
				sign = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
			},
			info = {
				severity = 3,
				colors = module.get_hl("DiagnosticVirtualTextInfo"),
				sign = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
			},
			hint = {
				severity = 4,
				colors = module.get_hl("DiagnosticVirtualTextHint"),
				sign = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
			},
		}
	end
	return module._diags_data
end

function module.diags_signs()
	return {
		DiagnosticSignError = module.diags().error,
		DiagnosticSignWarn = module.diags().warn,
		DiagnosticSignInfo = module.diags().info,
		DiagnosticSignHint = module.diags().hint,
	}
end

function module.diags_sorted()
	return {
		module.diags().error,
		module.diags().warn,
		module.diags().info,
		module.diags().hint,
	}
end

function module.diags_lines()
	return {
		"DiagnosticLineError",
		"DiagnosticLineWarn",
		"DiagnosticLineInfo",
		"DiagnosticLineHint",
	}
end

function module.diags_underlines()
	return {
		"DiagnosticUnderlineError",
		"DiagnosticUnderlineWarn",
		"DiagnosticUnderlineInfo",
		"DiagnosticUnderlineHint",
	}
end

module.separators = {
	left = "",
	left_lite = "",
	right = "",
	right_lite = "",
}

function module.darken(color, amount, bg)
	return require("catppuccin.utils.colors").darken(color, amount, bg)
end

function module.brighten(color, amount, bg)
	return require("catppuccin.utils.colors").brighten(color, amount, bg)
end

function module.palette()
	return require("catppuccin.palettes").get_palette()
end

function module.correct_channel(x)
	return 0.04045 < x and math.pow((x + 0.055) / 1.055, 2.4) or (x / 12.92)
end

function module.correct_lightness(x)
	local k1, k2 = 0.206, 0.03
	local k3 = (1 + k1) / (1 + k2)

	return 0.5 * (k3 * x - k1 + math.sqrt((k3 * x - k1) ^ 2 + 4 * k2 * k3 * x))
end

function module.cuberoot(x)
	return math.pow(x, 0.333333)
end

function module.compute_opposite_color(hex)
	local dec = tonumber(hex, 16)
	local b = module.correct_channel(math.fmod(dec, 256) / 255)
	local g = module.correct_channel(math.fmod((dec - b) / 256, 256) / 255)
	local r = module.correct_channel(math.floor(dec / 65536) / 255)

	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	local l_, m_, s_ = module.cuberoot(l), module.cuberoot(m), module.cuberoot(s)
	local L = module.correct_lightness(0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_)

	return L < 0.5 and module.palette().text or module.palette().base
end

local function fmt(color)
	if type(color) == "string" then
		return color
	elseif type(color) == "number" then
		return string.format("#%x", color)
	end
end

function module.build_pill(left, center, right, key)
	key = key or "provider"
	local colors = module.colors()
	local sep = module.separators
	local result = {
		insert = function(self, item)
			table.insert(self.content, item)
		end,
		content = {},
	}
	local function bg(color)
		if not color then
			color = {}
		end
		if not color.bg then
			local fg = color.fg
			if not fg then
				fg = module.palette().text
			end
			color.bg = module.darken(fmt(fg), 0.3)
		end
		return fmt(color.bg)
	end

	local prev_color = colors.normal
	for _, item in ipairs(left) do
		if not item.condition or item.condition() then
			result:insert {
				[key] = item.lite and sep.left_lite or sep.left,
				hl = {
					fg = item.lite and module.palette().base or bg(item.hl),
					bg = bg(prev_color),
				},
			}
			result:insert(item)
			prev_color = item.hl
		end
	end

	result:insert { [key] = sep.left, hl = { fg = bg(center.hl), bg = bg(prev_color) } }
	result:insert(center)
	prev_color = center.hl

	for _, item in ipairs(right) do
		if not item.condition or item.condition() then
			result:insert { [key] = sep.right, hl = { fg = bg(prev_color), bg = bg(item.hl) } }
			result:insert(item)
			prev_color = item.hl
		end
	end

	result:insert { [key] = sep.right, hl = { fg = bg(prev_color), bg = bg(colors.normal) } }

	return result.content
end

function module.diag_count_for_buffer(bufnr, diag_count)
	if not diag_count then
		diag_count = { 0, 0, 0, 0 }
	end

	for _, diag in ipairs(vim.diagnostic.get(bufnr)) do
		diag_count[diag.severity] = diag_count[diag.severity] + 1
	end

	return diag_count
end

function module.make_tablist(tab_component)
	local tablist = {
		init = function(self)
			local tabpages = vim.api.nvim_list_tabpages()
			for i, tabpage in ipairs(tabpages) do
				local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
				local child = self[i]
				if not (child and child.tabpage == tabpage) then
					self[i] = self:new(tab_component, i)
					child = self[i]
					child.tabnr = tabnr
					child.tabpage = tabpage
				end
				if tabpage == vim.api.nvim_get_current_tabpage() then
					child.is_active = true
					self.active_child = i
				else
					child.is_active = false
				end
			end
			if #self > #tabpages then
				for i = #self, #tabpages + 1, -1 do
					self[i] = nil
				end
			end
		end,
	}
	return tablist
end

function module.get_hl_group(hl)
	local group_name = "AutoGroup_"
	if hl.fg then
		group_name = group_name .. "_fg" .. fmt(hl.fg):gsub("#", "")
	end
	if hl.bg then
		group_name = group_name .. "_bg" .. fmt(hl.bg):gsub("#", "")
	end
	if hl.sp then
		group_name = group_name .. "_sp" .. fmt(hl.sp):gsub("#", "")
	end
	if hl.style then
		for _, style in ipairs(hl.style) do
			group_name = group_name .. "_" .. style
		end
	end
	if vim.fn.hlexists(group_name) then
		require("catppuccin.lib.highlighter").syntax {
			[group_name] = hl,
		}
	end

	return group_name
end

return module
