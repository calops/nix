return {
	-- Code definition and references peeking
	{
		"dnlhc/glance.nvim",
		cmd = "Glance",
		keys = {
			{ "gd", "<CMD>Glance definitions<CR>", desc = "Peek definition(s)" },
			{ "gr", "<CMD>Glance references<CR>", desc = "Peek references" },
			{ "gD", "<CMD>Glance type_definitions<CR>", desc = "Peek declarations" },
			{ "gi", "<CMD>Glance implementations<CR>", desc = "Peek implementations" },
		},
		opts = function()
			local actions = require("glance").actions
			return {
				height = 25,
				border = {
					enable = true,
					top_char = "▔",
					bottom_char = "▁",
				},
				theme = { enable = true, mode = "auto" },
				mappings = {
					list = {
						["<C-v>"] = actions.jump_vsplit,
						["<C-x>"] = actions.jump_split,
						["<C-t>"] = actions.jump_tab,
					},
				},
			}
		end,
	},
	-- Highlight symbols under cursor, LSP and treesitter-aware
	{
		"RRethy/vim-illuminate",
		event = "BufRead",
		config = function()
			require("illuminate").configure {
				large_file_cutoff = 2000,
				large_file_overrides = {
					providers = { "lsp" },
					under_cursor = true,
				},
			}
		end,
	},
	-- Diagnostics window
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = { { "<leader>t", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle diagnostics window" } },
		opts = {
			focus = true,
		},
	},
}
