local map = require("core.utils").map

return {
	-- Fuzzy finder
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		keys = function()
			local fzf = function(cmd) return "<cmd>FzfLua " .. cmd .. "<cr>" end
			map { "<leader>f", group = "fzf", icon = "", mode = { "n", "v" } }
			return {
				{ "<C-p>", fzf("files"), desc = "Find files" },
				{ "<leader>fb", fzf("buffers"), desc = "Find buffers" },
				{ "<leader>fs", fzf("live_grep"), desc = "Find string" },
				{ "<leader>fR", fzf("grep_last"), desc = "Find string again" },
				{ "<leader>fr", fzf("resume"), desc = "Resume latest search" },
				{ "<leader>ff", fzf("grep_cword"), desc = "Find string in files" },
				{ "<leader>ff", fzf("grep_visual"), desc = "Find string in files", mode = { "x" } },
				{ "<leader>fh", fzf("helptags"), desc = "Help tags" },
				{ "<leader>fg", fzf("git_branches"), desc = "Find git branch" },
				{ "<space>a", fzf("lsp_code_actions"), desc = "LSP code actions", mode = { "n", "x" } },
			}
		end,
		opts = { "default-title" },
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
	-- Icons
	{
		"echasnovski/mini.icons",
		opts = {},
		lazy = true,
		specs = {
			{ "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
		},
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			package.preload["nvim-web-devicons"] = function()
				-- needed since it will be false when loading and mini will fail
				package.loaded["nvim-web-devicons"] = {}
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
	-- Symbol picker
	{
		"ziontee113/icon-picker.nvim",
		cmd = { "IconPickerNormal" },
		keys = {
			{ "<leader>fe", "<cmd>IconPickerNormal<cr>", desc = "Pick icon" },
		},
		opts = { disable_legacy_commands = true },
	},
}
