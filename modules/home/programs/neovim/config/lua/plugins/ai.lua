return {
	{
		"zbirenbaum/copilot.lua",
		event = "VeryLazy",
		enabled = false,
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
		"olimorris/codecompanion.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			adapters = {
				http = {
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							env = { api_key = [[cmd:op read "op://Private/Gemini API key/password"]] },
						})
					end,
				},
			},
			strategies = {
				chat = { adapter = "gemini" },
				inline = { adapter = "gemini" },
				cmd = { adapter = "gemini" },
			},
		},
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
			auto_suggestions_provider = "gemini",
			providers = {
				gemini = {
					model = "gemini-2.5-pro-exp-03-25",
				},
			},
			hints = { enabled = false },
			windows = { ask = { start_insert = false } },
			mappings = {
				submit = {
					normal = "<C-CR>",
					insert = "<C-CR>",
				},
			},
			-- system_prompt = function()
			-- 	local hub = require("mcphub").get_hub_instance()
			-- 	return hub and hub:get_active_servers_prompt() or ""
			-- end,
			-- custom_tools = function() return { require("mcphub.extensions.avante").mcp_tool() } end,
		},
	},

	-- Model Context Protocol
	{
		"ravitemer/mcphub.nvim",
		enabled = true,
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "MCPHub",
		build = "bundled_build.lua",
		opts = {
			config = vim.fn.expand("~/.config/nvim/mcphub-servers.json"),
			use_bundled_binary = true,
		},
	},
	{
		"Exafunction/windsurf.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("codeium").setup {
				enable_cmp_source = false,
				tools = {
					language_server = vim.g.codeium_language_server_path,
				},
				virtual_text = {
					enabled = true,
					key_bindings = {
						accept = "<M-CR>",
						accept_word = "<M-w>",
						accept_line = "<M-l>",
						next = "<M-Right>",
						prev = "<M-Left>",
						clear = "<C-:>",
					},
				},
			}
		end,
	},
}
