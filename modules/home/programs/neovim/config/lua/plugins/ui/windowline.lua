local colors = require("core.colors")
local hl = colors.hl
local utils = require("plugins.ui.utils")
local diag = require("core.diagnostics")

return {
	"b0o/incline.nvim",
	enabled = not vim.g["started_by_firenvim"],
	event = "UIEnter",
	config = function()
		local function f(color) return string.format("#%06x", color) end

		local incline = require("incline")

		incline.setup {
			render = function(props)
				local buftype = vim.bo[props.buf].buftype
				local filename_modifier = buftype == "help" and ":t" or ":."
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), filename_modifier)
					or "[no name]"
				local filetype = vim.bo[props.buf].filetype
				local modified = vim.bo[props.buf].modified
				local icon, icon_hl = require("mini.icons").get("filetype", filetype)

				local col_inactive = f(hl.InclineNormalNC.bg)
				local col_active = f(hl.InclineNormal.bg)
				local col_base = f(hl.Normal.bg)
				local col_modified = f(hl.CustomTablineModifiedIcon.fg)
				local col_icon_fg = f(hl[icon_hl].fg)

				if buftype == "terminal" then
					filename = vim.b[props.buf].term_title
					icon = ""
					icon_hl = "TermFloatBorder"
				end

				local icon_color = {
					fg = col_icon_fg,
					bg = colors.darken(col_icon_fg, 0.3),
				}

				local color = col_inactive
				if props.focused then
					color = col_active
				end

				local result = {
					{ "", guifg = icon_color.bg, guibg = col_base, blend = 100 },
					{ icon .. "  ", guifg = icon_color.fg, guibg = icon_color.bg },
					{ "", guifg = color, guibg = icon_color.bg },
					{ filename, guibg = color },
				}

				local diag_counts = utils.diag_count_for_buffer(props.buf)
				local prev_color = color

				for severity, count in ipairs(diag_counts) do
					if count > 0 then
						local sigh_hl = diag.sign_hl(severity)
						table.insert(result, { "", guifg = prev_color, guibg = f(sigh_hl.bg) })
						table.insert(result, {
							" " .. diag.sign(severity) .. count,
							guifg = f(sigh_hl.fg),
							guibg = f(sigh_hl.bg),
						})
						prev_color = f(sigh_hl.bg)
					end
				end

				if modified then
					local bg = colors.darken(col_modified, 0.3)
					table.insert(result, { "", guifg = prev_color, guibg = bg })
					table.insert(result, { "  ", guifg = col_modified, guibg = bg })
					prev_color = bg
				end

				table.insert(result, { "", guifg = prev_color, guibg = col_base, blend = 100 })

				return result
			end,

			hide = { cursorline = true },

			ignore = {
				unlisted_buffers = false,
				buftypes = function(_, buftype) return buftype ~= "" and buftype ~= "help" and buftype ~= "terminal" end,
			},

			window = {
				padding = 0,
				placement = { horizontal = "center", vertical = "bottom" },
				margin = {
					horizontal = { left = 1, right = 1 },
					vertical = { bottom = 1, top = 2 },
				},
			},
		}
	end,
}
