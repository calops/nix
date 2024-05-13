local map = require("core.utils").map
return {
	-- Show rich inline diagnostics
	{
		url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		event = "LspAttach",
		init = function()
			local function toggle_virtual_lines()
				local is_enabled = vim.diagnostic.config().virtual_lines

				vim.diagnostic.config {
					virtual_lines = (not is_enabled) and { highlight_whole_line = false },
					virtual_text = is_enabled,
					severity_sort = true,
				}
			end

			map {
				["<leader>m"] = {
					function()
						require("lsp_lines")
						toggle_virtual_lines()
					end,
					"Toggle full inline diagnostics",
				},
			}
		end,
		config = function()
			require("lsp_lines").setup()

			vim.diagnostic.config {
				signs = true,
				severity_sort = true,
				virtual_lines = false,
			}
		end,
	},
	-- Code definition and references peeking
	{
		"dnlhc/glance.nvim",
		cmd = "Glance",
		init = function()
			map {
				g = {
					d = { "<CMD>Glance definitions<CR>", "Peek definition(s)" },
					r = { "<CMD>Glance references<CR>", "Peek references" },
					D = { "<CMD>Glance type_definitions<CR>", "Peek declarations" },
					i = { "<CMD>Glance implementations<CR>", "Peek implementations" },
				},
			}
		end,
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
		init = function()
			map {
				["<leader>t"] = {
					function() require("trouble").toggle() end,
					"Toggle diagnostics window",
				},
			}
		end,
		config = true,
	},
}
