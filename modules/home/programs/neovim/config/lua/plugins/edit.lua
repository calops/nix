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
		keys = {
			{ "gs", function() require("treesj").toggle() end, desc = "Toggle split" },
		},
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
		keys = function()
			local dp = function(opts)
				return function() return require("debugprint").debugprint(opts) end
			end
			map {
				{ "<leader>p", group = "debug print", icon = "" },
			}
			return {
				{ "<leader>pp", dp(), desc = "Add debug print below", expr = true },
				{ "<leader>pP", dp { above = true }, desc = "Add debug print above", expr = true },
				{
					"<leader>pv",
					dp { variable = true },
					desc = "Add variable debug print below",
					expr = true,
					mode = { "n", "o" },
				},
				{
					"<leader>pV",
					dp { variable = true, above = true },
					desc = "Add variable debug print above",
					expr = true,
					mode = { "n", "o" },
				},
				{ "<leader>pd", ":DeleteDebugPrints<CR>", desc = "Delete debug prints" },
				{
					"<leader>p",
					dp { variable = true },
					desc = "Add variable debug print below",
					expr = true,
					mode = { "x" },
				},
				{
					"<leader>P",
					dp { variable = true, above = true },
					desc = "Add variable debug print above",
					expr = true,
					mode = { "x" },
				},
			}
		end,
		config = true,
	},
	-- Edit filesystem as a buffer
	{
		"stevearc/oil.nvim",
		keys = {
			{ "<leader>o", "<cmd>Oil --float<cr>", desc = "Edit filesystem as a buffer" },
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
			{ "f", function() require("flash").jump() end, desc = "Jump to target", mode = { "n", "x", "o" } },
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
			{ "<leader>y", '"+y', desc = "Copy to system clipboard", mode = { "n", "v", "x" } },
			{ "gp", "<Plug>YankyPreviousEntry", desc = "Previous yank" },
			{ "gn", "<Plug>YankyNextEntry", desc = "Next yank" },
		},
	},
	-- Substitute operator
	{
		"gbprod/substitute.nvim",
		lazy = true,
		keys = {
			{ "s", function() require("substitute").operator() end, desc = "Substitute" },
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
		keys = {
			mode = { "n", "x", "o", "i" },
			{ "<C-Left>", function() require("spider").motion("b") end, desc = "Move backwards word-wise" },
			{ "<C-Right>", function() require("spider").motion("w") end, desc = "Move forwards word-wise" },
		},
	},
	{
		"gabrielpoca/replacer.nvim",
		ft = "qf",
		init = function()
			-- Create binding only for qf filetype
			vim.api.nvim_create_autocmd("BufRead", {
				callback = function(args)
					if vim.bo.filetype == "qf" then
						map { "i", function() require("replacer").run() end, buffer = args.buf }
					end
				end,
			})
		end,
	},
}
