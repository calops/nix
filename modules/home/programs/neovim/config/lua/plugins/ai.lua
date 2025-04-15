local utils = require("core.utils")

return {
	{
		"zbirenbaum/copilot.lua",
		event = "VeryLazy",
		opts = {
			copilot_model = "gpt-4o-copilot",
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
		branch = "main",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		cmd = "CopilotChat",
		opts = {
			model = "gpt-4.1",
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
					selection = function() return require("CopilotChat.select").gitdiff() end,
				},
			},
		},
		keys = function()
			local function pick_with_selection(selection)
				return function()
					require("CopilotChat").select_prompt {
						selection = require("CopilotChat.select")[selection],
					}
				end
			end
			utils.map {
				{ "<leader>c", group = "copilot", icon = "", mode = { "n", "x" } },
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

	-- AI companion
	{
		"yetone/avante.nvim",
		build = "make",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = { insert_mode = true },
					},
				},
			},
		},
		event = "VeryLazy",
		init = function()
			require("core.utils").map {
				{ "<leader>a", group = "ai", icon = " ", mode = { "n", "x" } },
			}
		end,
		---@module "avante"
		---@type avante.Config
		opts = {
			provider = "copilot",
			auto_suggestions_provider = "copilot",
			hints = { enabled = false },
			windows = { ask = { start_insert = false } },
			mappings = {
				submit = {
					normal = "<C-CR>",
					insert = "<C-CR>",
				},
			},
			system_prompt = function()
				local hub = require("mcphub").get_hub_instance()
				return hub and hub:get_active_servers_prompt() or ""
			end,
			custom_tools = function() return { require("mcphub.extensions.avante").mcp_tool() } end,
		},
	},

	-- Model Context Protocol
	{
		"ravitemer/mcphub.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "MCPHub",
		build = "bundled_build.lua",
		opts = {
			config = vim.fn.expand("~/.config/nvim/mcphub-servers.json"),
			use_bundled_binary = true,
		},
	},
}
