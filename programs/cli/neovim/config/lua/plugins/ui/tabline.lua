local utils = require("plugins.ui.utils")
local colors = require("core.colors")
local core_diagnostics = require("core.diagnostics")

vim.go.laststatus = 0
vim.go.showtabline = 2

local function map_to_names(client_list)
	return vim.tbl_map(function(client) return client.name end, client_list)
end

local spacer = {
	provider = function() return "%=" end,
}

local mode = {
	static = {
		modes = {
			n = { "NORMAL", "ModeNormal" },
			no = { "NORMAL?", "ModeOperator" },
			v = { "VISUAL", "ModeVisual" },
			V = { "VISUAL-L", "ModeVisual" },
			[""] = { "VISUAL-B", "ModeVisual" },
			s = { "SELECT", "ModeVisual" },
			S = { "SELECT-L", "ModeVisual" },
			[""] = { "SELECT-B", "ModeVisual" },
			i = { "INSERT", "ModeInsert" },
			R = { "REPLACE", "ModeReplace" },
			c = { "COMMAND", "ModeCommand" },
			["!"] = { "SHELL", "ModeCommand" },
			r = { "PROMPT", "ModePrompt" },
			t = { "TERMINAL", "ModeTerminal" },
		},
	},
	init = function(self)
		local short_mode = vim.fn.mode(1) or "n"
		local mode = self.modes[short_mode:sub(1, 2)] or self.modes[short_mode:sub(1, 1)] or { "UNKNOWN", "ModeNormal" }
		local hl = colors.hl[mode[2]]

		self[1] = self:new(
			utils.build_pill(
				{},
				{ provider = " ", hl = { fg = colors.palette().base, bg = hl.fg } },
				{ { provider = " " .. mode[1], hl = hl } },
				"provider"
			),
			1
		)
	end,
	update = { "ModeChanged" },
	provider = " ",
	hl = { bold = true },
}

local cwd = {
	init = function(self)
		local icon = (vim.fn.haslocaldir(0) == 1 and "local: " or "") .. " "
		local cwd = vim.fn.fnamemodify(vim.fn.getcwd(0), ":~")
		local short_cwd = vim.fn.pathshorten(cwd)

		self[1] = self:new(
			utils.build_pill({}, {
				provider = icon .. cwd,
				hl = colors.hl.CustomTablineCwd,
			}, {}, "provider"),
			1
		)
		self[2] = self:new(
			utils.build_pill({}, {
				provider = icon .. short_cwd,
				hl = colors.hl.CustomTablineCwd,
			}, {}, "provider"),
			2
		)
	end,
	provider = " ",
	flexible = 10,
}

local git = {
	condition = require("heirline.conditions").is_git_repo,
	init = function(self)
		local status = vim.b.gitsigns_status_dict
		self[1] = self:new(
			utils.build_pill(
				{ { provider = " " .. status.head .. " ", hl = colors.hl.CustomTablineGitBranch } },
				{ provider = " ", hl = colors.hl.CustomTablineGitLogo },
				{},
				"provider"
			),
			1
		)
	end,
	update = { "BufEnter", "BufWritePost" },
	provider = " ",
}

local tabs = {
	init = function(self) self.tabpages = vim.api.nvim_list_tabpages() end,
	static = {
		diags = utils.diags_sorted(),
	},
	{
		condition = function(self) return not vim.tbl_isempty(self.tabpages) end,
		flexible = 1,
		{ provider = "󱂬 ", hl = colors.hl.CustomTablineLogo },
	},
	{
		condition = function(self) return not vim.tbl_isempty(self.tabpages) end,
		utils.make_tablist {
			init = function(self)
				local devicons = require("nvim-web-devicons")
				local function compute_icon_color(color)
					if self.is_active then
						return color
					end
					return colors.darken(color, 0.4, string.format("#%x", colors.hl.CustomTablinePillIcon.bg))
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

					if not self.tab_name and win == vim.api.nvim_tabpage_get_win(self.tabpage) then
						self.tab_name = file_name
					end

					if self.is_active then
						self.tab_color = colors.hl.CustomTablineSel
						self.pill_color = colors.hl.CustomTablinePillIconSel
					else
						self.tab_color = colors.hl.CustomTabline
						self.pill_color = colors.hl.CustomTablinePillIcon
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
							hl = { fg = colors.hl.CustomTablineModifiedIcon.fg },
						},
					}),
					2
				)
				self[3] = self:new({ provider = "%T" }, 3)
			end,
			provider = " ",
		},
	},
}

local lsp = {
	condition = function(self)
		self.active_clients = vim.lsp.get_clients()
		return not vim.tbl_isempty(self.active_clients)
	end,
	update = { "LspAttach", "LspDetach", "BufEnter", "DiagnosticChanged" },
	init = function(self)
		local servers = {}
		local active_clients = map_to_names(self.active_clients)
		local buffer_clients = map_to_names(vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() })

		for _, client in ipairs(active_clients) do
			table.insert(servers, {
				provider = client .. " ",
				hl = vim.tbl_contains(buffer_clients, client) and colors.hl.CustomTablineLspActive
					or colors.hl.CustomTablineLspInactive,
				lite = true,
			})
		end

		local diagnostics = {}
		core_diagnostics.for_each_severity(function(severity)
			local diag_count = vim.diagnostic.get(nil, { severity = severity })
			if #diag_count > 0 then
				table.insert(diagnostics, {
					provider = " " .. core_diagnostics.map[severity].sign .. #diag_count,
					hl = core_diagnostics.map[severity].colors,
				})
			end
		end)

		self[1] = self:new(
			utils.build_pill(servers, { provider = " ", hl = colors.hl.CustomTablineLsp }, diagnostics, "provider"),
			1
		)
		self[2] = self:new({ provider = " " }, 2)
	end,
}

return {
	-- Left
	{ mode, cwd, git, spacer },
	-- Center
	{ tabs, spacer },
	-- Right
	{ lsp },
}
