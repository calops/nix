local utils = require("core.utils")

return {
	-- Plugins manager
	-- Defined and pinned here so that it's excluded from updates
	{
		"folke/lazy.nvim",
		pin = true,
	},
	-- Session management
	{
		"olimorris/persisted.nvim",
		lazy = false,
		init = function()
			vim.opt.sessionoptions = {
				"buffers",
				"curdir",
				"folds",
				"globals",
				"help",
				"tabpages",
				"winpos",
				"winsize",
			}
			local group = vim.api.nvim_create_augroup("PersistedHooks", {})
			local ignored_file_types = { "Trouble", "neo-tree", "noice" }

			utils.user_aucmd("PersistedSavePre", function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local file_type = vim.api.nvim_get_option_value("filetype", { buf = buf })
					if vim.tbl_contains(ignored_file_types, file_type) then
						vim.api.nvim_command("silent! bwipeout! " .. buf)
					end
				end
			end, { group = group })
		end,
		opts = {
			use_git_branch = true,
			autosave = true,
			autoload = false,
			follow_cwd = false,
		},
	},
	-- Startup time analyzer
	{
		"dstein64/vim-startuptime",
		lazy = false,
		enabled = false,
	},
	-- Auto close buffers
	{
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = { retirementAgeMins = 10 },
	},
	{
		"glacambre/firenvim",
		lazy = not vim.g.started_by_firenvim,
		priority = 100,
		build = function() vim.fn["firenvim#install"](0) end,
		init = function()
			vim.g.firenvim_config = {
				localSettings = {
					[".*"] = {
						cmdline = "neovim",
						takeover = "never",
					},
				},
			}
		end,
	},
	-- Direnv sync
	{
		"direnv/direnv.vim",
		lazy = false,
	},
}
