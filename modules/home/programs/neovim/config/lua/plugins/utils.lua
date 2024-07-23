local utils = require("core.utils")

return {
	-- Session management
	{
		"olimorris/persisted.nvim",
		lazy = false,
		keys = {
			{ "<leader>P", ":Telescope persisted<CR>", desc = "Browse sessions" },
		},
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
			autoload = true,
			follow_cwd = false,
		},
	},
	-- Startup time analyzer
	{
		"dstein64/vim-startuptime",
		lazy = false,
		enabled = false,
	},
	-- Floating terminal window
	{
		"akinsho/toggleterm.nvim",
		name = "toggleterm",
		cmd = "ToggleTerm",
		keys = {
			{
				"<C-f>",
				function() require("toggleterm").toggle() end,
				desc = "Toggle floating terminal",
				mode = { "n", "t" },
			},
		},
		opts = {
			direction = "float",
			float_opts = { border = "rounded" },
			highlights = { FloatBorder = { link = "TermFloatBorder" } },
		},
	},
	-- Auto close buffers
	{
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 10,
		},
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
