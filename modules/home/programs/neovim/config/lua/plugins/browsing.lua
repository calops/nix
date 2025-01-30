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
				-- TODO:
				-- { "<space>a", fzf("lsp_code_actions"), desc = "LSP code actions", mode = { "n", "x" } },
			}
		end,
	},
	-- File tree browser
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "<leader>nn", ":Neotree toggle reveal_force_cwd<cr>", desc = "Toggle file browser" },
			{ "<leader>ng", ":Neotree toggle git_status<cr>", desc = "Show git status" },
			{ "<leader>nb", ":Neotree toggle buffers<cr>", desc = "Show open buffers" },
		},
		init = function() map { "<leader>n", group = "file tree", icon = "" } end,
		opts = {
			popup_border_style = "rounded",
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
			source_selector = {
				winbar = true,
				statusline = false,
			},
			default_component_configs = {
				modified = {
					symbol = "",
				},
				git_status = {
					symbols = {
						unstaged = "",
					},
				},
			},
		},
	},
}
