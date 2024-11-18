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
			{ "<leader>gB", "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<cr>", desc = "Review branch changes" },
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
		keys = function()
			local function g() return require("gitsigns") end
			return {
				{ "<leader>gu", function() g().undo_stage_hunk() end, desc = 'Undo "stage hunk"' },
				{ "<leader>gn", function() g().nav_hunk("next") end, desc = "Next hunk" },
				{ "<leader>gN", function() g().nav_hunk("prev") end, desc = "Previous hunk" },
				{ "<leader>gp", function() g().preview_hunk_inline() end, desc = "Preview hunk" },
				{ "<leader>gs", function() g().stage_hunk() end, desc = "Stage hunk", mode = { "n" } },
				{ "<leader>gr", function() g().reset_hunk() end, desc = "Stage hunk", mode = { "n" } },
				{
					"<leader>gs",
					function() g().stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
					desc = "Stage hunk",
					mode = { "x" },
				},
				{
					"<leader>gr",
					function() g().reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
					desc = "Stage hunk",
					mode = { "x" },
				},
			}
		end,
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
	{
		"andrewradev/linediff.vim",
		cmd = { "Linediff" },
	},
}
