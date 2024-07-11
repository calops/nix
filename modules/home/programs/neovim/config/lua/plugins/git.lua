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
		init = function()
			map {
				["<leader>g"] = {
					name = "git",
					s = { function() require("gitsigns").stage_hunk() end, "Stage hunk" },
					u = { function() require("gitsigns").undo_stage_hunk() end, 'Undo "stage hunk"' },
					r = { function() require("gitsigns").reset_hunk() end, "Reset hunk" },
					n = { function() require("gitsigns").next_hunk() end, "Next hunk" },
					N = { function() require("gitsigns").prev_hunk() end, "Previous hunk" },
					p = { function() require("gitsigns").preview_hunk_inline() end, "Preview hunk" },
				},
			}
		end,
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
}
