local map = require("core.utils").map

return {
	{
		"zbirenbaum/copilot.lua",
		enabled = true,
		event = "VeryLazy",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<M-CR>",
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					next = "<M-Right>",
					prev = "<M-Left>",
					dismiss = "<C-:>",
				},
			},
			filetypes = {
				yaml = true,
				gitcommit = true,
				markdown = true,
			},
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		enabled = true,
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		lazy = true,
		opts = {
			question_header = "##   User ――――――――――――――――――――――",
			answer_header = "##   Copilot ―――――――――――――――――――",
			error_header = "##   Error ―――――――――――――――――――――",
			separator = "",
			show_folds = false,
			context = "buffer",
			window = {
				layout = "vertical",
				width = 120,
				height = 0.8,
				relative = "editor",
				border = "rounded",
				zindex = 50,
			},
		},
		init = function()
			local function pick_with_selection(selection)
				return function()
					local actions = require("CopilotChat.actions")
					actions.pick(actions.prompt_actions { selection = require("CopilotChat.select")[selection] })
				end
			end
			map({
				["<leader>c"] = {
					name = "copilot",
					c = { function() require("CopilotChat").toggle() end, "Toggle Copilot Chat" },
					b = { pick_with_selection("buffer"), "Actions on buffer" },
					a = { pick_with_selection("buffers"), "Actions on all buffers" },
					s = { pick_with_selection("visual"), "Actions on selection" },
				},
			}, { mode = { "n", "v", "x" } })
		end,
		config = function(opts)
			require("CopilotChat").setup(opts)
			require("core.utils").make_sidebar(
				"copilot-chat",
				function() return vim.fn.bufname() == "copilot-chat" and vim.fn.win_gettype() ~= "popup" end
			)
		end,
	},
	{
		"supermaven-inc/supermaven-nvim",
		enabled = false, -- Bugged for now
		opts = {
			keymaps = {
				accept_suggestion = "<M-CR>",
				clear_suggestion = "<C-]>",
			},
		},
	},
	{
		"Exafunction/codeium.vim",
		enabled = false, -- Bugged for now
		event = "VeryLazy",
		config = function()
			vim.g.codeium_disable_bindings = 1
			map {
				["<M-CR>"] = { "call codeium#Accept()", "Accept suggestion", mode = "i" },
			}
		end,
	},
}
