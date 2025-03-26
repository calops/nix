return {
	-- Universal language parser
	{
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		build = function() vim.cmd("TSUpdate") end,
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
					require("syntax-tree-surfer")
					vim.opt.opfunc = op
					return "g@l"
				end
			end

			-- stylua: ignore
			return {
				{ "<M-Up>", dr("v:lua.STSSwapUpNormal_Dot"), desc = "Swap node upwards", expr = true },
				{ "<M-Down>", dr("v:lua.STSSwapDownNormal_Dot"), desc = "Swap node downwards", expr = true },
				{ "<M-Left>", dr("v:lua.STSSwapCurrentNodePrevNormal_Dot"), desc = "Swap with previous node", expr = true },
				{ "<M-Right>", dr("v:lua.STSSwapCurrentNodeNextNormal_Dot"), desc = "Swap with next node", expr = true },
				{ "<Cr>", ":STSSelectCurrentNode<CR>", desc = "Select current node" },
				{ "<M-Up>", "<CMD>STSSwapPrevVisual<CR>", desc = "Swap with previous node" , mode = "x" },
				{ "<M-Down>", "<CMD>STSSwapNextVisual<CR>", desc = "Swap with next node" , mode = "x" },
				{ "<M-Left>", "<CMD>STSSwapPrevVisual<CR>", desc = "Swap with previous node" , mode = "x" },
				{ "<M-Right>", "<CMD>STSSwapNextVisual<CR>", desc = "Swap with next node" , mode = "x" },
				{ "<C-Up>", "<CMD>STSSelectPrevSiblingNode<CR>", desc = "Select previous sibling" , mode = "x" },
				{ "<C-Down>", "<CMD>STSSelectNextSiblingNode<CR>", desc = "Select next sibling" , mode = "x" },
				{ "<C-Left>", "<CMD>STSSelectPrevSiblingNode<CR>", desc = "Select previous sibling" , mode = "x" },
				{ "<C-Right>", "<CMD>STSSelectNextSiblingNode<CR>", desc = "Select next sibling" , mode = "x" },
				{ "<Cr>", "<CMD>STSSelectParentNode<CR>", desc = "Select parent node" , mode = "x" },
				{ "<S-Cr>", "<CMD>STSSelectChildNode<CR>", desc = "Select child node" , mode = "x" },
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
}
