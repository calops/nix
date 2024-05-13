local map = require("core.utils").map

return {
	-- Comment commands
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring.internal").calculate_commentstring()
						or vim.bo.commentstring
				end,
			},
		},
	},
	-- Split/join
	{
		"Wansmer/treesj",
		lazy = true,
		init = function()
			map {
				["gs"] = {
					function() require("treesj").toggle() end,
					"Toggle split",
				},
			}
		end,
		opts = {
			max_join_length = 300,
		},
		config = true,
	},
	-- Automatically adjust indentation settings depending on the file
	{
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		config = true,
	},
	-- Surround text objects
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = true,
	},
	-- Word families substitutions
	{
		"johmsalas/text-case.nvim",
		event = "VeryLazy",
		opts = {
			prefix = "gS",
			substitude_command_name = "S",
		},
	},
	-- Debug print statements
	{
		"andrewferrier/debugprint.nvim",
		lazy = true,
		init = function()
			local debugprint = function(opts)
				return function() return require("debugprint").debugprint(opts) end
			end
			map {
				["<leader>p"] = {
					name = "debug print",
					p = { debugprint(), "Add debug print below", expr = true },
					P = { debugprint { above = true }, "Add debug print above", expr = true },
					v = {
						debugprint { variable = true },
						"Add variable debug print below",
						expr = true,
						mode = { "n", "o" },
					},
					V = {
						debugprint { variable = true, above = true },
						"Add variable debug print above",
						expr = true,
						mode = { "n", "o" },
					},
					d = { ":DeleteDebugPrints<CR>", "Delete debug prints" },
				},
				["<leader>"] = {
					p = {
						debugprint { variable = true },
						"Add variable debug print below",
						expr = true,
						mode = { "x" },
					},
					P = {
						debugprint { variable = true, above = true },
						"Add variable debug print above",
						expr = true,
						mode = { "x" },
					},
				},
			}
		end,
		config = true,
	},
	-- Edit filesystem as a buffer
	{
		"stevearc/oil.nvim",
		keys = {
			{ "<leader>o", "<cmd>Oil --float<cr>", "Edit filesystem as a buffer" },
		},
		lazy = false,
		opts = {
			columns = { "icon" },
			view_options = {
				show_hidden = true,
			},
			float = {
				padding = 5,
				max_width = 120,
				max_height = 200,
			},
		},
	},
	-- Move stuff around
	{
		"echasnovski/mini.move",
		event = "VeryLazy",
		opts = {
			mappings = {
				left = "<S-Left>",
				right = "<S-Right>",
				down = "<S-Down>",
				up = "<S-Up>",
				line_left = "<S-Left>",
				line_right = "<S-Right>",
				line_down = "<S-Down>",
				line_up = "<S-Up>",
			},
		},
	},
	-- Align stuff
	{
		"echasnovski/mini.align",
		event = "VeryLazy",
		config = true,
	},
	-- Move around
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			search = {
				mode = "fuzzy",
				incremental = true,
			},
			modes = {
				char = {
					enabled = false,
				},
			},
		},
		keys = {
			{ "f", mode = { "n", "x", "o" }, function() require("flash").jump() end },
		},
	},
	-- Improved yanking
	{
		"gbprod/yanky.nvim",
		event = "BufRead",
		dependencies = { "kkharji/sqlite.lua" },
		opts = { ring = {
			storage = "sqlite",
			cancel_event = "move",
		} },
		keys = {
			{
				"<C-y>",
				function() require("telescope").extensions.yank_history.yank_history() end,
				desc = "Yank history",
			},
			{ "<leader>y", '"+y', "Copy to system clipboard", mode = { "n", "v", "x" } },
			{ "gp", "<Plug>YankyPreviousEntry", "Previous yank" },
			{ "gn", "<Plug>YankyNextEntry", "Next yank" },
		},
	},
	-- Substitute operator
	{
		"gbprod/substitute.nvim",
		lazy = true,
		keys = {
			{ "s", function() require("substitute").operator() end, desc = "Substitute", mode = "n" },
			{ "s", function() require("substitute").visual() end, desc = "Substitute", mode = "x" },
			{ "ss", function() require("substitute").line() end, desc = "Substitute line" },
			{ "S", function() require("substitute").eol() end, desc = "Substitute until end of line" },
		},
		opts = {
			on_substitute = function() require("yanky.integration").substitute() end,
		},
	},
	-- More convenient word motions
	{
		"chrisgrieser/nvim-spider",
		init = function()
			map({
				["<C-Left>"] = { "<cmd>lua require('spider').motion('b')<cr>", "Move backwards word-wise" },
				["<C-Right>"] = { "<cmd>lua require('spider').motion('w')<cr>", "Move forwards word-wise" },
			}, { mode = { "n", "x", "o", "i" } })
		end,
	},
	{
		"gabrielpoca/replacer.nvim",
		ft = "qf",
		init = function()
			-- Create binding only for qf filetype
			vim.api.nvim_create_autocmd("BufRead", {
				callback = function()
					if vim.bo.filetype == "qf" then
						vim.keymap.set("n", "i", function() require("replacer").run() end, { buffer = 0 })
					end
				end,
			})
		end,
	},
}
