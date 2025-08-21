local utils = require("plugins.ui.utils")
local colors = require("core.colors")
local core_diagnostics = require("core.diagnostics")
local git_utils = require("core.git")
local core_utils = require("core.utils")

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
				{ provider = " ", hl = { fg = colors.palette().base, bg = hl.fg } },
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

local macro = {
	condition = function(self)
		self.recording_reg = vim.fn.reg_recording()
		return self.recording_reg ~= ""
	end,
	init = function(self)
		self[1] = self:new(
			utils.build_pill({}, { provider = " ", hl = colors.hl.MacroRecording }, {
				{
					provider = " " .. self.recording_reg,
					hl = { fg = colors.hl.MacroRecording.bg },
				},
			}, "provider"),
			1
		)
	end,
	update = { "RecordingEnter", "RecordingLeave" },
	provider = " ",
}

local cwd = {
	init = function(self)
		local icon = (vim.fn.haslocaldir(0) == 1 and "local " or "") .. " "
		local cwd = vim.fn.fnamemodify(vim.fn.getcwd(0), ":~")

		local icon_pill = { provider = icon, hl = colors.hl.CustomTablineCwdIcon }

		self[1] = self:new(
			utils.build_pill(
				{},
				icon_pill,
				{ {
					provider = " " .. cwd,
					hl = colors.hl.CustomTablineCwd,
				} },
				"provider"
			),
			1
		)
		self[2] = self:new(
			utils.build_pill({}, icon_pill, {
				{
					provider = function() return " " .. vim.fn.pathshorten(cwd) end,
					hl = colors.hl.CustomTablineCwd,
				},
			}, "provider"),
			1
		)
	end,
	provider = " ",
	flexible = 10,
}

local git = {
	update = {
		"User",
		pattern = "GitStatusUpdated",
		callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
	},
	condition = function() return git_utils.status.is_git_repo end,
	init = function(self)
		self[1] = self:new(
			utils.build_pill({
				{
					provider = "  ",
					hl = colors.hl.CustomTablineGitBranch,
					lite = true,
					condition = function() return git_utils.status.has_stash end,
				},
			}, { provider = " ", hl = colors.hl.CustomTablineGitIcon }, {
				{
					provider = "  " .. git_utils.status.head,
					hl = colors.hl.CustomTablineGitBranch,
					condition = function() return git_utils.status.head ~= nil end,
				},
			}, "provider"),
			1
		)
	end,
	provider = " ",
}

---@type table<number, string>
local tab_names = {}

local function serialize_tab_names_for_session()
	local tab_names_sorted = {}
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		table.insert(tab_names_sorted, tab_names[tabpage])
	end
	vim.g.TabNamesJson = vim.fn.json_encode(tab_names_sorted)
end

local function deserialize_tab_names_from_session()
	if vim.g.TabNamesJson then
		local tab_names_sorted = vim.fn.json_decode(vim.g.TabNamesJson)
		for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
			tab_names[tabpage] = tab_names_sorted[i]
		end
	end
end

core_utils.aucmd("SessionLoadPost", deserialize_tab_names_from_session)

core_utils.aucmd("TabClosed", function(data)
	local tabpage = tonumber(data.file)
	table.remove(tab_names, tabpage)
	serialize_tab_names_for_session()
end)

core_utils.map {
	{
		"<leader>;",
		function()
			local tabpage = vim.api.nvim_get_current_tabpage()
			vim.ui.input({ prompt = "Tab name: " }, function(input)
				if input == "" then
					input = nil
				end
				tab_names[tabpage] = input
				serialize_tab_names_for_session()
			end)
		end,
		desc = "Set tab name",
	},
}

local tabs = {
	init = function(self) self.tabpages = vim.api.nvim_list_tabpages() end,
	{
		condition = function(self) return not vim.tbl_isempty(self.tabpages) end,
		flexible = 1,
		{ provider = "󱂬 ", hl = colors.hl.CustomTablineLogo },
	},
	{
		condition = function(self) return not vim.tbl_isempty(self.tabpages) end,
		utils.make_tablist {
			init = function(self)
				local function compute_icon_color(color)
					if self.is_active then
						return color
					end
					return colors.darken(color, 0.4, colors.hl.CustomTablinePillIcon.bg)
				end

				local icons = {}
				local diag_count = { 0, 0, 0, 0 }
				local modified = false
				self.tab_name = tab_names[self.tabpage]
				self.wins = vim.api.nvim_tabpage_list_wins(self.tabpage)
				for _, win in ipairs(self.wins) do
					local buffer = vim.api.nvim_win_get_buf(win)
					local buffer_name = vim.api.nvim_buf_get_name(buffer) or ""
					local file_name = vim.fs.basename(buffer_name)
					local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })
					local buftype = vim.api.nvim_get_option_value("buftype", { buf = buffer })

					if filetype and buftype ~= "nofile" then
						local icon, icon_hl = require("mini.icons").get("filetype", filetype)
						if icon and icon_hl then
							table.insert(icons, {
								provider = icon,
								hl = { fg = compute_icon_color(colors.hl[icon_hl].fg or colors.hl.Normal.fg) },
							})
						end
					end

					diag_count = utils.diag_count_for_buffer(buffer, diag_count)

					if self.tab_name == nil and win == vim.api.nvim_tabpage_get_win(self.tabpage) then
						self.tab_name = file_name
					end

					if self.is_active then
						self.tab_color = colors.hl.CustomTablineSel
						self.pill_color = colors.hl.CustomTablinePillIconSel
					else
						self.tab_color = colors.hl.CustomTabline
						self.pill_color = colors.hl.CustomTablinePillIcon
					end

					modified = modified or vim.api.nvim_get_option_value("modified", { buf = buffer })
				end

				table.insert(icons, { provider = " " })

				local diags = require("core.diagnostics")
				local diag_pills = {}
				local first = true
				for severity, count in ipairs(diag_count) do
					if count > 0 then
						if first then
							table.insert(diag_pills, { provider = " " })
							first = false
						end
						table.insert(diag_pills, {
							provider = diags.sign(severity),
							hl = { fg = compute_icon_color(string.format("#%06x", diags.sign_hl(severity).fg)) },
						})
					end
				end

				if not self.tab_name then
					self.tab_name = "[no name]"
				end

				self[1] = self:new(
					utils.build_pill({
						{ hl = self.pill_color, icons, lite = not self.is_active },
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
							hl = colors.hl.CustomTablineModifiedIcon,
						},
					}),
					1
				)

				self.on_click = {
					name = "set_current_tabpage_" .. self.tabpage,
					callback = function() vim.api.nvim_set_current_tabpage(self.tabpage) end,
				}
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
		local counted_clients = {}

		for _, client in ipairs(active_clients) do
			counted_clients[client] = (counted_clients[client] or 0) + 1
		end

		for client, count in pairs(counted_clients) do
			local text = client
			if count > 1 then
				text = text .. " ×" .. count
			end
			text = text .. " "

			table.insert(servers, {
				provider = text,
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
					provider = " " .. core_diagnostics.sign(severity) .. #diag_count,
					hl = core_diagnostics.sign_hl(severity),
				})
			end
		end)

		self[1] = self:new(
			utils.build_pill(servers, { provider = " ", hl = colors.hl.CustomTablineLsp }, diagnostics, "provider"),
			1
		)
		self[2] = self:new({ provider = " " }, 2)
	end,
}

return {
	-- Left
	{ mode, macro, cwd, git, spacer },
	-- Center
	{ tabs, spacer },
	-- Right
	{ lsp },
}
