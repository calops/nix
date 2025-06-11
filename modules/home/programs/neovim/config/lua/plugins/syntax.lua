return {
	-- Universal language parser
	{
		"nvim-treesitter/nvim-treesitter",
		-- The new main branch removed a bunch of features for some reason so here we are
		branch = "master",
		event = "BufRead",
		build = ":TSUpdate",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
		},
		keys = {
			{ "<leader>T", ":Inspect<CR>", desc = "Show highlighting groups and captures" },
		},
		config = function()
			if vim.gcc_bin_path ~= nil then
				require("nvim-treesitter.install").compilers = { vim.g.gcc_bin_path }
			end

			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup {
				auto_install = true,
				ensure_installed = { "json", "markdown", "markdown_inline", "regex" },
				indent = { enable = true },
				matchup = { enable = true },
				playground = { enable = true },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						node_incremental = "v",
						node_decremental = "M-v",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = { query = "@function.outer", desc = "outer function" },
							["if"] = { query = "@function.inner", desc = "inner function" },
							["ac"] = { query = "@class.outer", desc = "outer class" },
							["ic"] = { query = "@class.inner", desc = "inner class" },
							["an"] = { query = "@parameter.outer", desc = "outer parameter" },
							["in"] = { query = "@parameter.inner", desc = "inner parameter" },
						},
					},
					swap = { enable = true },
				},
				query_linter = {
					enable = true,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
				},
			}
		end,
	},
	-- {
	-- 	"MeanderingProgrammer/treesitter-modules.nvim",
	-- 	dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- 	opts = {
	-- 		ensure_installed = { "json", "markdown", "markdown_inline", "regex" },
	-- 		highlight = {
	-- 			enable = true,
	-- 			additional_vim_regex_highlighting = false,
	-- 		},
	-- 		incremental_selection = {
	-- 			enable = false,
	-- 			disable = false,
	-- 			keymaps = {
	-- 				init_selection = "gnn",
	-- 				node_incremental = "grn",
	-- 				scope_incremental = "grc",
	-- 				node_decremental = "grm",
	-- 			},
	-- 		},
	-- 		indent = {
	-- 			enable = false,
	-- 			disable = false,
	-- 		},
	-- 	},
	-- },
	-- Show sticky context for off-screen scope beginnings
	{
		"nvim-treesitter/nvim-treesitter-context",
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
	-- Playground treesitter utility
	{
		"nvim-treesitter/playground",
		cmd = "TSPlaygroundToggle",
	},
	-- Syntax-aware text objects and motions
	{
		"ziontee113/syntax-tree-surfer",
		cmd = {
			"STSSwapPrevVisual",
			"STSSwapNextVisual",
			"STSSelectPrevSiblingNode",
			"STSSelectNextSiblingNode",
			"STSSelectParentNode",
			"STSSelectChildNode",
			"STSSwapOrHold",
			"STSSelectCurrentNode",
		},
		keys = function()
			--- Dot repeatable
			local function dr(op)
				return function()
					if vim.treesitter.get_parser() then
						require("syntax-tree-surfer")
						vim.opt.opfunc = "v:lua." .. op .. "_Dot"
						return "g@l"
					end
				end
			end

			local function ts_guard(cmd)
				return function()
					if vim.treesitter.get_parser() then
						vim.cmd(cmd)
					end
				end
			end

			return {
				{ "<M-Up>", dr("STSSwapUpNormal"), desc = "Swap node upwards", expr = true },
				{ "<M-Down>", dr("STSSwapDownNormal"), desc = "Swap node downwards", expr = true },
				{ "<M-Left>", dr("STSSwapCurrentNodePrevNormal"), desc = "Swap with previous node", expr = true },
				{ "<M-Right>", dr("STSSwapCurrentNodeNextNormal"), desc = "Swap with next node", expr = true },
				{ "<M-Up>", ts_guard("STSSwapPrevVisual"), desc = "Swap with previous node", mode = "x" },
				{ "<M-Down>", ts_guard("STSSwapNextVisual"), desc = "Swap with next node", mode = "x" },
				{ "<M-Left>", ts_guard("STSSwapPrevVisual"), desc = "Swap with previous node", mode = "x" },
				{ "<M-Right>", ts_guard("STSSwapNextVisual"), desc = "Swap with next node", mode = "x" },
				{ "<C-Up>", ts_guard("STSSelectPrevSiblingNode"), desc = "Select previous sibling", mode = "x" },
				{ "<C-Down>", ts_guard("STSSelectNextSiblingNode"), desc = "Select next sibling", mode = "x" },
				{ "<C-Left>", ts_guard("STSSelectPrevSiblingNode"), desc = "Select previous sibling", mode = "x" },
				{ "<C-Right>", ts_guard("STSSelectNextSiblingNode"), desc = "Select next sibling", mode = "x" },
				{ "<Cr>", ts_guard("STSSelectCurrentNode"), desc = "Select current node" },
				{ "<Cr>", ts_guard("STSSelectCurrentNode"), desc = "Select parent node", mode = "x" },
				{ "<S-Cr>", ts_guard("STSSelectChildNode"), desc = "Select child node", mode = "x" },
			}
		end,
		config = true,
	},
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
