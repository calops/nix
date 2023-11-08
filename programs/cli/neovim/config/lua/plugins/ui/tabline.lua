local utils = require("plugins.ui.utils")
local colors = require("core.colors")

return {
	init = function(self) self.tabpages = vim.api.nvim_list_tabpages() end,
	{
		condition = function(self) return not vim.tbl_isempty(self.tabpages) end,
		static = {
			sep = utils.separators,
			diags = utils.diags_sorted(),
			colors = {
				logo = colors.hl.CustomTablineLogo,
				tab_active = colors.hl.CustomTablineSel,
				tab_inactive = colors.hl.CustomTabline,
				icon_pill_inactive = colors.hl.CustomTablinePillIcon,
				icon_pill_active = colors.hl.CustomTablinePillIconSel,
				icon_modified = colors.hl.CustomTablineModifiedIcon,
			},
		},
		{
			provider = "%=",
		},
		-- Logo
		{
			utils.build_pill({}, { provider = " Tabs", hl = colors.hl.CustomTablineLogo }, {}, "provider"),
		},
		-- Tabs
		utils.make_tablist {
			init = function(self)
				local devicons = require("nvim-web-devicons")
				local function compute_icon_color(color)
					if self.is_active then
						return color
					end
					return colors.darken(color, 0.4, string.format("#%x", self.colors.icon_pill_inactive.bg))
				end

				local icons = {}
				local diag_count = { 0, 0, 0, 0 }
				local modified = false
				self.tab_name = nil
				self.wins = vim.api.nvim_tabpage_list_wins(self.tabpage)
				for _, win in ipairs(self.wins) do
					local buffer = vim.api.nvim_win_get_buf(win)
					local buffer_name = vim.api.nvim_buf_get_name(buffer) or ""
					local file_name = buffer_name:match("^.+/(.+)$")
					if file_name then
						local icon, icon_color = devicons.get_icon_color(file_name, file_name:match("^.+%.(.+)$"))
						if icon and icon_color then
							table.insert(icons, {
								provider = icon .. " ",
								hl = { fg = compute_icon_color(icon_color) },
							})
						end
					end

					diag_count = utils.diag_count_for_buffer(buffer, diag_count)

					if not self.tab_name then
						self.tab_name = file_name
					end

					if self.is_active then
						self.tab_color = self.colors.tab_active
						self.pill_color = self.colors.icon_pill_active
					else
						self.tab_color = self.colors.tab_inactive
						self.pill_color = self.colors.icon_pill_inactive
					end

					if vim.api.nvim_get_option_value("modified", { buf = buffer }) then
						modified = true
					end
				end

				local diag_pills = {}
				local first = true
				for i, count in ipairs(diag_count) do
					if count > 0 then
						if first then
							table.insert(diag_pills, { provider = " " })
							first = false
						end
						table.insert(diag_pills, {
							provider = self.diags[i].sign,
							hl = { fg = compute_icon_color(string.format("#%x", self.diags[i].colors.fg)) },
						})
					end
				end

				if not self.tab_name then
					self.tab_name = "[no name]"
				end

				self[1] = self:new({ provider = "%" .. self.tabnr .. "T" }, 1)
				self[2] = self:new(
					utils.build_pill({
						{ hl = self.pill_color, icons },
					}, {
						hl = self.tab_color,
						{
							{ provider = self.tabpage .. " ", hl = "CustomTablineNumber" },
							{ provider = self.tab_name },
						},
					}, {
						{
							hl = self.pill_color,
							condition = function() return not vim.tbl_isempty(diag_pills) end,
							diag_pills,
						},
						{
							provider = "  ",
							condition = function() return modified end,
							hl = { fg = self.colors.icon_modified.fg },
						},
					}),
					2
				)
				self[3] = self:new({ provider = "%T" }, 3)
			end,
			provider = " ",
		},
		{
			provider = "%=",
		},
	},
}
