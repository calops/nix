local error_query = vim.treesitter.query.parse("query", "[(ERROR)(MISSING)] @a")
local namespace = vim.api.nvim_create_namespace("treesitter.diagnostics")

--- @param args vim.api.keyset.create_autocmd.callback_args
local function diagnose(args)
	if not vim.diagnostic.is_enabled { bufnr = args.buf } then
		return
	end
	-- don't diagnose strange stuff
	if vim.bo[args.buf].buftype ~= "" then
		return
	end

	local diagnostics = {}
	local parser = vim.treesitter.get_parser(args.buf, nil, { error = false })
	if parser then
		parser:parse(false, function(_, trees)
			if not trees then
				return
			end
			parser:for_each_tree(function(tree, ltree)
				-- skip languages which never error and are very common injections
				if ltree:lang() ~= "comment" and ltree:lang() ~= "markdown" then
					for _, node in error_query:iter_captures(tree:root(), args.buf) do
						local lnum, col, end_lnum, end_col = node:range()

						-- collapse nested syntax errors that occur at the exact same position
						local parent = node:parent()
						if parent and parent:type() == "ERROR" and parent:range() == node:range() then
							goto continue
						end

						-- clamp large syntax error ranges to just the line to reduce noise
						if end_lnum > lnum then
							end_lnum = lnum + 1
							end_col = 0
						end

						--- @type vim.Diagnostic
						local diagnostic = {
							source = "treesitter",
							lnum = lnum,
							end_lnum = end_lnum,
							col = col,
							end_col = end_col,
							message = "",
							code = string.format("%s-syntax", ltree:lang()),
							bufnr = args.buf,
							namespace = namespace,
							severity = vim.diagnostic.severity.ERROR,
						}
						if node:missing() then
							diagnostic.message = string.format("missing `%s`", node:type())
						else
							diagnostic.message = "error"
						end

						-- add context to the error using sibling and parent nodes
						local previous = node:prev_sibling()
						if previous and previous:type() ~= "ERROR" then
							local previous_type = previous:named() and previous:type()
								or string.format("`%s`", previous:type())
							diagnostic.message = diagnostic.message .. " after " .. previous_type
						end

						if
							parent
							and parent:type() ~= "ERROR"
							and (previous == nil or previous:type() ~= parent:type())
						then
							diagnostic.message = diagnostic.message .. " in " .. parent:type()
						end

						table.insert(diagnostics, diagnostic)
						::continue::
					end
				end
			end)
		end)
		vim.diagnostic.set(namespace, args.buf, diagnostics)
	end
end

local autocmd_group = vim.api.nvim_create_augroup("editor.treesitter", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "InsertLeave" }, {
	desc = "treesitter diagnostics",
	group = autocmd_group,
	callback = vim.schedule_wrap(diagnose),
})

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
				{
					"gO",
					function()
						require("syntax-tree-surfer").go_to_top_node_and_execute_commands(false, {
							"normal! O",
							"normal! O",
							"startinsert",
						})
					end,
					desc = "Insert above top-level node",
				},
				{
					"go",
					function()
						require("syntax-tree-surfer").go_to_top_node_and_execute_commands(true, {
							"normal! o",
							"normal! o",
							"startinsert",
						})
					end,
					desc = "Insert below top-level node",
				},
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
