local utils = require("core.utils")

return {
	-- Comment commands
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {},
	},
	-- Split/join
	{
		"Wansmer/treesj",
		lazy = true,
		keys = {
			{ "<space>s", function() require("treesj").toggle() end, desc = "Toggle split" },
		},
		opts = {
			max_join_length = 300,
			use_default_keymaps = false,
		},
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
		"Goose97/timber.nvim",
		lazy = true,
		---@module "timber"
		---@type Timber.InitConfig
		opts = {
			template_placeholders = {
				insert_cursor = function(ctx)
					local placement = ctx.log_position == "above" and "before" or "after"
					return "%%log_marker "
						.. vim.fn.fnamemodify(vim.fn.bufname(), ":t")
						.. ":"
						.. vim.fn.line(".")
						.. ": "
						.. placement
						.. " "
						.. vim.trim(vim.fn.getline(".")):gsub('"', ""):sub(1, 50)
				end,
			},
			default_keymaps_enabled = false,
			log_marker = "🔴🔴🔴DEBUG🔴🔴🔴",
			log_templates = {
				default = {
					elixir = [[IO.inspect(%log_target, label: "%log_marker %log_target", syntax_colors: IO.ANSI.syntax_colors())]],
					lua = [[print("%log_marker %log_target=", %log_target)]],
				},
				plain = {
					elixir = [[IO.puts("%insert_cursor")]],
				},
			},
		},
		init = function()
			local log = function(position, template)
				return function()
					require("timber.actions").insert_log {
						position = position or "below",
						template = template or "default",
					}
				end
			end

			utils.map {
				{ "<leader>p", group = "debug logs", icon = "" },
				{ "<leader>pp", log("below", "plain"), desc = "Debug log below", icon = " " },
				{ "<leader>pP", log("above", "plain"), desc = "Debug log above", icon = " " },
				{ "<leader>pv", log("below"), desc = "Variable log below", icon = " 󰫧 ", mode = { "n", "x" } },
				{ "<leader>pV", log("above"), desc = "Variable log above", icon = " 󰫧 ", mode = { "n", "x" } },
			}
		end,
	},
	-- Edit filesystem as a buffer
	{
		"stevearc/oil.nvim",
		lazy = false,
		keys = {
			{ "<leader>o", "<cmd>Oil<cr>", desc = "Edit filesystem as a buffer" },
		},
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
		opts = {
			search = {
				mode = "fuzzy",
				incremental = true,
			},
			modes = { char = { enabled = false } },
		},
		keys = {
			{ "f", function() require("flash").jump() end, desc = "Jump to target", mode = { "n", "x", "o" } },
		},
	},
	-- Improved yanking
	{
		"gbprod/yanky.nvim",
		dependencies = { "kkharji/sqlite.lua" },
		event = "VeryLazy",
		opts = { ring = {
			storage = "sqlite",
			cancel_event = "move",
		} },
		cmd = { "YankyRingHistory" },
		keys = {
			{ "<C-y>", "<cmd>YankyRingHistory<cr>", desc = "Yank history" },
			{ "<leader>y", '"+y', desc = "Copy to system clipboard", mode = { "n", "v", "x" } },
		},
		init = function()
			-- Remove trailing whitespace from visual block yanks
			vim.api.nvim_create_autocmd("TextYankPost", {
				callback = function()
					local event = vim.v.event
					if event.regtype:sub(1, 1) ~= "" or not event.visual then
						return
					end
					local content = {}
					for _, line in ipairs(event.regcontents) do
						table.insert(content, vim.fn.trim(line, "", 2))
					end
					vim.fn.setreg(event.regname, content)
				end,
			})
		end,
	},
	{
		"echasnovski/mini.operators",
		opts = {
			evaluate = { prefix = "g=" },
			exchange = { prefix = "gR" },
			multiply = { prefix = "gm" },
			replace = { prefix = "gx" },
			sort = { prefix = "gs" },
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
	-- Better and editable quickfix
	{
		"stevearc/quicker.nvim",
		event = "VeryLazy",
		opts = {
			keys = {
				{
					">",
					function() require("quicker").expand { before = 2, after = 2, add_to_existing = true } end,
					desc = "Expand quickfix context",
				},
				{
					"<",
					function() require("quicker").collapse() end,
					desc = "Collapse quickfix context",
				},
			},
		},
	},
	-- Structural search/replace
	{
		"cshuaimin/ssr.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>rs",
				function() require("ssr").open() end,
				mode = { "n", "x" },
				desc = "Structural search/replace",
			},
		},
		opts = {},
	},
}
