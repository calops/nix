local map = require("core.utils").map

return {
	-- Diff viewer and merge tool
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Open file history" },
		},
		opts = {
			enhanced_diff_hl = true,
			use_icons = true,
			view = {
				default = { layout = "diff2_horizontal" },
				merge_tool = {
					layout = "diff4_mixed",
					disable_diagnostics = true,
				},
			},
		},
	},
	-- Git utilities, gutter signs
	{
		"lewis6991/gitsigns.nvim",
		event = "BufRead",
		keys = {
			{ "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
			{ "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = 'Undo "stage hunk"' },
			{ "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
			{ "<leader>gn", function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
			{ "<leader>gN", function() require("gitsigns").prev_hunk() end, desc = "Previous hunk" },
			{ "<leader>gp", function() require("gitsigns").preview_hunk_inline() end, desc = "Preview hunk" },
		},
		init = function() map { "<leader>g", group = "git", icon = "" } end,
		opts = {
			preview_config = { border = "rounded" },
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "╏" },
				topdelete = { text = "╏" },
				changedelete = { text = "╏" },
				untracked = { text = "┋" },
			},
		},
	},
	-- Git commands
	{
		"tpope/vim-fugitive",
		cmd = "Git",
	},
	-- Github integration
	{
		"pwntester/octo.nvim",
		lazy = true,
		cmd = "Octo",
		opts = {
			use_local_fs = true,
			enable_builtin = true,
		},
	},
	{
		"ruifm/gitlinker.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		opts = { mappings = nil },
		init = function()
			-- No idea why this is necessary but the following doesn't set the mapping for modes x and v if using the
			-- `keys` field in init
			map {
				{
					"<leader>gy",
					function() require("gitlinker").get_buf_range_url("n") end,
					desc = "Yank git line URL",
					mode = "n",
				},
				{
					"<leader>gy",
					function() require("gitlinker").get_buf_range_url("v") end,
					desc = "Yank git lines URL",
					mode = { "x", "v" },
				},
			}
		end,
		keys = {
			{
				"<leader>go",
				function()
					require("gitlinker").get_repo_url {
						action_callback = require("gitlinker.actions").open_in_browser,
					}
				end,
				desc = "Open git repo in browser",
			},
		},
	},
	{
		"topaxi/gh-actions.nvim",
		keys = {
			{ "<leader>ga", "<cmd>GhActions<cr>", desc = "Open Github Actions" },
		},
		opts = {},
	},
	{ "andrewradev/linediff.vim" },
}
