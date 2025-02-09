local map = require("core.utils").map

return {
	-- Fuzzy finder
	{
		"folke/snacks.nvim",

		---@type snacks.Config
		opts = {
			picker = { ui_select = true },
		},

		keys = function()
			local picker = function(command, ...)
				local args = ...
				return function() Snacks.picker[command](args) end
			end

			map { "<leader>f", group = "finder", icon = "", mode = { "n", "v" } }

			return {
				{ "<C-p>", picker("smart"), desc = "Find files" },
				{ "<leader>fb", picker("buffers"), desc = "Find buffers" },
				{ "<leader>fs", picker("grep"), desc = "Find string" },
				{ "<leader>fr", picker("resume"), desc = "Resume latest search" },
				{ "<leader>ff", picker("grep_word"), desc = "Find string in files", mode = { "x", "n" } },
				{ "<leader>fh", picker("help"), desc = "Help tags" },
				{ "<leader>fH", picker("highlights"), desc = "Highlights" },
				{ "<leader>fg", picker("git_branches"), desc = "Git branches" },
				{ "<leader>fe", picker("icons"), desc = "Icons and emojis" },
				{ "<leader>fS", picker("projects"), desc = "Open session" },
				{ "<leader>fp", picker("lazy"), desc = "Find plugin" },
				{ "<leader>fe", picker("explorer"), desc = "Find plugin" },
				{
					"<leader>fy",
					picker("lsp_symbols", { layout = { preset = "sidebar", preview = "main" } }),
					desc = "Find plugin",
				},
				-- TODO:
				-- { "<space>a", fzf("lsp_code_actions"), desc = "LSP code actions", mode = { "n", "x" } },
			}
		end,
	},
}
