return {
	{
		"folke/snacks.nvim",

		---@type snacks.Config
		opts = function()
			return {
				dashboard = {
					enabled = true,
					sections = {
						{ section = "keys", gap = 1, padding = 1 },
						{
							pane = 2,
							icon = " ",
							title = "Recent Files",
							section = "recent_files",
							indent = 2,
							padding = 1,
						},
						{
							pane = 2,
							icon = " ",
							title = "Projects",
							section = "projects",
							indent = 2,
							padding = 1,
						},
						{
							pane = 2,
							icon = " ",
							title = "Git Status",
							section = "terminal",
							enabled = require("snacks").git.get_root() ~= nil,
							cmd = "hub status --short --branch --renames",
							height = 5,
							padding = 1,
							ttl = 5 * 60,
							indent = 3,
						},
						{ section = "startup" },
					},
				},
			}
		end,
	},
}
