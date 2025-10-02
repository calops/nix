return {
	-- Universal language parsers
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		priority = 10001,
		build = ":TSUpdate",
		dependencies = {},
		keys = {
			{ "<leader>T", vim.show_pos, desc = "Show highlighting groups and captures" },
		},
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = function()
			local select_textobject = function(scope)
				return function() require("nvim-treesitter-textobjects.select").select_textobject(scope, "textobjects") end
			end
			return {
				{ "af", select_textobject("@function.outer"), desc = "Select outer function", mode = { "x", "o" } },
				{ "if", select_textobject("@function.inner"), desc = "Select inner function", mode = { "x", "o" } },
				{ "ac", select_textobject("@class.outer"), desc = "Select outer class", mode = { "x", "o" } },
				{ "ic", select_textobject("@class.inner"), desc = "Select inner class", mode = { "x", "o" } },
				{ "an", select_textobject("@parameter.outer"), desc = "Select outer parameter", mode = { "x", "o" } },
				{ "in", select_textobject("@parameter.inner"), desc = "Select inner parameter", mode = { "x", "o" } },
			}
		end,
		opts = {
			select = {
				lookahead = true,
				selection_modes = {
					["@parameter.outer"] = "v",
					["@function.outer"] = "v",
					["@class.outer"] = "V",
				},
				include_surrounding_whitespace = false,
			},
		},
	},
	-- Automatically setup most of treesitter features
	{
		"MeanderingProgrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		lazy = false,
		opts = {
			ensure_installed = { "vim", "lua", "json", "markdown", "markdown_inline", "regex" },
			auto_install = true,
			indent = { enable = true },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<CR>",
					node_decremental = "<S-CR>",
				},
			},
		},
	},
	-- Show sticky context for off-screen scope beginnings
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		opts = {
			enable = true,
			max_lines = 5,
			trim_scope = "outer",
			zindex = 40,
			mode = "cursor",
			separator = nil,
		},
	},
	-- Syntax-aware and motions
	{
		"aaronik/treewalker.nvim",
		keys = {
			{ "<M-Up>", "<CMD>Treewalker SwapUp<CR>", desc = "Swap node upwards" },
			{ "<M-Down>", "<CMD>Treewalker SwapDown<CR>", desc = "Swap node downwards" },
			{ "<M-Left>", "<CMD>Treewalker SwapLeft<CR>", desc = "Swap with previous sibling" },
			{ "<M-Right>", "<CMD>Treewalker SwapRight<CR>", desc = "Swap with next sibling" },
		},
		opts = {},
	},
	-- Nix language injections
	{
		"calops/hmts.nvim",
		enabled = false,
		dev = false,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {
			signs = false,
		},
	},
	-- Indent text objects
	{ "michaeljsmith/vim-indent-object" },
}
