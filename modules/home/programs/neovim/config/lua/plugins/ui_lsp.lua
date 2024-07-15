local map = require("core.utils").map
return {
	-- Show rich inline diagnostics
	{
		url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		event = "LspAttach",
		keys = {
			{
				"<leader>m",
				function()
					require("lsp_lines")
					local is_enabled = vim.diagnostic.config().virtual_lines

					vim.diagnostic.config {
						virtual_lines = (not is_enabled) and { highlight_whole_line = false },
						virtual_text = is_enabled,
						severity_sort = true,
					}
				end,
				desc = "Toggle full inline diagnostics",
			},
		},
		config = function()
			require("lsp_lines").setup()

			vim.diagnostic.config {
				severity_sort = true,
				virtual_lines = false,
			}
		end,
	},
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
						["<C-g>"] = actions.jump_tab,
					},
				},
			}
		end,
	},
	-- Highlight symbols under cursor, LSP and treesitter-aware
	{
		"RRethy/vim-illuminate",
		event = "BufRead",
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
