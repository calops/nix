return {
	"b0o/incline.nvim",
	enabled = not vim.g.started_by_firenvim,
	event = "UIEnter",
	config = function()
		local function format_color(color) return string.format("#%x", color) end

		local incline = require("incline")
		local colors = require("core.colors")
		local utils = require("plugins.ui.utils")

		local col_inactive = format_color(colors.hl.InclineNormalNC.bg)
		local col_active = format_color(colors.hl.InclineNormal.bg)
		local col_base = format_color(colors.hl.Normal.bg)
		local col_modified = format_color(colors.hl.CustomTablineModifiedIcon.fg)
		local diags = utils.diags_sorted()

		incline.setup {
			render = function(props)
				local filename_modifier = vim.api.nvim_get_option_value("buftype", { buf = props.buf }) == "help"
						and ":t"
					or ":."
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), filename_modifier)
					or "[no name]"
				local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf })
				local extension = filename:match("^.+%.(.+)$")
				local icon, icon_fg_color =
					require("nvim-web-devicons").get_icon_colors(filename, extension, { default = true })

				local icon_color = {
					fg = icon_fg_color,
					bg = colors.darken(icon_fg_color, 0.3),
				}

				local color = col_inactive
				if props.focused then
					color = col_active
				end

				local result = {
					{ "", guifg = icon_color.bg, guibg = col_base, blend = 100 },
					{ icon .. "  ", guifg = icon_color.fg, guibg = icon_color.bg },
					{ "", guifg = color, guibg = icon_color.bg },
					{ filename },
				}

				local diag_counts = utils.diag_count_for_buffer(props.buf)
				local prev_color = color

				for i, count in ipairs(diag_counts) do
					if count > 0 then
						table.insert(result, { "", guifg = prev_color, guibg = format_color(diags[i].colors.bg) })
						table.insert(result, {
							" " .. diags[i].sign .. count,
							guifg = format_color(diags[i].colors.fg),
							guibg = format_color(diags[i].colors.bg),
						})
						prev_color = format_color(diags[i].colors.bg)
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
				buftypes = function(_, buftype) return buftype ~= "" and buftype ~= "help" end,
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
