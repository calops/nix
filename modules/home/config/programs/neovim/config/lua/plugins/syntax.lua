local map = require("core.utils").map

return {
	-- Universal language parser
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = function() vim.cmd("TSUpdate") end,
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
		},
		init = function()
			map {
				["<leader>T"] = { ":Inspect<CR>", "Show highlighting groups and captures" },
			}
		end,
		config = function()
			if vim.gcc_bin_path ~= nil then
				require("nvim-treesitter.install").compilers = { vim.g.gcc_bin_path }
			end

			require("nvim-treesitter.configs").setup {
				auto_install = true,
				ensure_installed = {
					"bash",
					"fish",
					"json",
					"lua",
					"markdown",
					"nix",
					"python",
					"rust",
					"toml",
					"vim",
					"regex",
					"jsonc",
					"markdown_inline",
				},
				indent = { enable = true },
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
					lsp_interop = {
						enable = true,
						border = "rounded",
						peek_definition_code = {
							["<leader>df"] = "@function.outer",
							["<leader>dF"] = "@class.outer",
						},
					},
				},
				matchup = {
					enable = true,
				},
				playground = { enable = true },
				query_linter = {
					enable = true,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
				},
			}
		end,
	},
	{ "JoosepAlviste/nvim-ts-context-commentstring" },
	-- Show sticky context for off-screen scope beginnings
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufRead",
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
	-- RON syntax plugin
	{
		"ron-rs/ron.vim",
		ft = "ron",
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
		},
		init = function()
			local function dot_repeatable(op)
				require("syntax-tree-surfer")
				return function()
					vim.opt.opfunc = op
					return "g@l"
				end
			end

			map {
				["<M-Up>"] = { dot_repeatable("v:lua.STSSwapUpNormal_Dot"), "Swap node upwards", expr = true },
				["<M-Down>"] = { dot_repeatable("v:lua.STSSwapDownNormal_Dot"), "Swap node downwards", expr = true },
				["<M-Left>"] = {
					dot_repeatable("v:lua.STSSwapCurrentNodePrevNormal_Dot"),
					"Swap with previous node",
					expr = true,
				},
				["<M-Right>"] = {
					dot_repeatable("v:lua.STSSwapCurrentNodeNextNormal_Dot"),
					"Swap with next node",
					expr = true,
				},
				["gO"] = {
					function()
						require("syntax-tree-surfer").go_to_top_node_and_execute_commands(false, {
							"normal! O",
							"normal! O",
							"startinsert",
						})
					end,
					"Insert above top-level node",
				},
				["go"] = {
					function()
						require("syntax-tree-surfer").go_to_top_node_and_execute_commands(true, {
							"normal! o",
							"normal! o",
							"startinsert",
						})
					end,
					"Insert below top-level node",
				},
				["gh"] = { "<CMD>STSSwapOrHold<CR>", "Hold or swap with held node" },
				["<Cr>"] = { "<CMD>STSSelectCurrentNode<CR>", "Select current node" },
			}

			map({
				["<M-Up>"] = { "<CMD>STSSwapPrevVisual<CR>", "Swap with previous node" },
				["<M-Down>"] = { "<CMD>STSSwapNextVisual<CR>", "Swap with next node" },
				["<M-Left>"] = { "<CMD>STSSwapPrevVisual<CR>", "Swap with previous node" },
				["<M-Right>"] = { "<CMD>STSSwapNextVisual<CR>", "Swap with next node" },
				["<C-Up>"] = { "<CMD>STSSelectPrevSiblingNode<CR>", "Select previous sibling" },
				["<C-Down>"] = { "<CMD>STSSelectNextSiblingNode<CR>", "Select next sibling" },
				["<C-Left>"] = { "<CMD>STSSelectPrevSiblingNode<CR>", "Select previous sibling" },
				["<C-Right>"] = { "<CMD>STSSelectNextSiblingNode<CR>", "Select next sibling" },
				["<Cr>"] = { "<CMD>STSSelectParentNode<CR>", "Select parent node" },
				["<S-Cr>"] = { "<CMD>STSSelectChildNode<CR>", "Select child node" },
				["gh"] = { "<CMD>STSSwapOrHold<CR>", "Hold or swap with held node" },
			}, { mode = "x" })
		end,
		config = true,
	},
	-- Yuck support
	{
		"elkowar/yuck.vim",
		ft = "yuck",
	},
	{
		"calops/hmts.nvim",
		enabled = false,
		dev = false,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
	},
}
