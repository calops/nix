local map = require("core.utils").map

return {
	-- Diff viewer and merge tool
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
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
			preview_config = {
				border = "rounded",
			},
			_signs_staged_enable = true,
			_extmark_signs = false,
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
		"NeogitOrg/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		opts = {
			disable_builtin_notifications = true,
			kind = "tab",
			popup = { kind = "vsplit" },
			commit_popup = { kind = "vsplit" },
			commit = { kind = "vsplit" },
			preview_buffer = { kind = "vsplit" },
			integrations = {
				telescope = true,
				diffview = true,
			},
		},
	},
}
