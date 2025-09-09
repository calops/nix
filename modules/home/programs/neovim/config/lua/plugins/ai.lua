return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"ravitemer/mcphub.nvim",
		},
		keys = {
			{ "<leader>ac", "<cmd>CodeCompanionChat toggle<cr>", desc = "Code companion", mode = { "n", "x" } },
			{ "<leader>aa", "<cmd>CodeCompanion<cr>", desc = "Code companion", mode = { "n", "x" } },
		},
		cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
		init = function()
			require("core.utils").map {
				{ "<leader>a", group = "ai", icon = " ", mode = { "n", "x" } },
			}
		end,
		opts = {
			adapters = {
				acp = {
					gemini_cli = function()
						return require("codecompanion.adapters").extend("gemini_cli", {
							-- defaults = { auth_method = "gemini-api-key" },
							-- env = { api_key = [[cmd:op read "op://Private/Gemini API key/password"]] },
						})
					end,
				},
				http = {
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							env = { api_key = [[cmd:op read "op://Private/Gemini API key/password"]] },
						})
					end,
				},
			},
			strategies = {
				chat = { adapter = "gemini_cli" },
				inline = { adapter = "gemini" },
				cmd = { adapter = "gemini" },
			},
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
					opts = {
						make_vars = true,
						make_slash_commands = true,
						show_result_in_chat = true,
					},
				},
			},
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
