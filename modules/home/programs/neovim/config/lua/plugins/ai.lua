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
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		cmd = "CopilotChat",
		opts = {
			question_header = "##   User ",
			answer_header = "##   Copilot ",
			error_header = "##   Error ",
			separator = "―――――――",
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
			prompts = {
				CommitStaged = {
					prompt = [[
Write commit message for the change with commitizen convention.
MAKE SURE the title has MAXIMUM 50 characters (INCLUDING the conventional commits prefix) and message is WRAPPED at 72 characters.
The message should only contain SUCCINT, terse bullet points starting with '-'.
You should strive to avoid being redundant across bulletpoints.
One feature should most times have only one bullet point.
When writing a bullet point about neovim plugins, make sure to mention the name of the plugin.
Wrap the whole message in code block with language gitcommit.
Once you're done with the bullet points, DO NOT write anything else.
Very important points to remember: be SUCCINT, make sure the title is under 50 characters, and that the bullet points are wrapped at 72 characters.
]],
					selection = function(source) return require("CopilotChat.select").gitdiff(source, true) end,
				},
			},
		},
		keys = function()
			local function pick_with_selection(selection)
				return function()
					local actions = require("CopilotChat.actions")
					actions.pick(actions.prompt_actions { selection = require("CopilotChat.select")[selection] })
				end
			end
			require("core.utils").map {
				{ "<leader>c", group = "copilot", icon = "" },
			}
			return {
				{
					"<leader>cc",
					function() require("CopilotChat").toggle() end,
					desc = "Toggle Copilot Chat",
					mode = { "n", "x" },
				},
				{ "<leader>cb", pick_with_selection("buffer"), desc = "Actions on buffer", mode = { "n", "x" } },
				{ "<leader>ca", pick_with_selection("buffers"), desc = "Actions on all buffers", mode = { "n", "x" } },
				{ "<leader>cs", pick_with_selection("visual"), desc = "Actions on selection", mode = { "n", "x" } },
			}
		end,
	},
}
