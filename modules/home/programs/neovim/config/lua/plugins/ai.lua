return {
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
	{
		"folke/sidekick.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<M-tab>",
				function()
					if not require("sidekick").nes_jump_or_apply() then
						vim.notify("No suggestion available", "info", { style = "minimal" })
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
				mode = { "n", "i" },
			},
			{
				"<c-;>",
				function() require("sidekick.cli").toggle { name = "gemini", focus = true } end,
				desc = "Sidekick Toggle CLI",
				mode = { "n", "v", "t" },
			},
			{
				"<leader>ap",
				function() require("sidekick.cli").select_prompt() end,
				desc = "Sidekick Ask Prompt",
				mode = { "n", "v" },
			},
		},
		opts = {
			cli = {
				win = {
					layout = "float",
					float = { border = "rounded" },
				},
				mux = {
					backend = "zellij",
					enabled = true,
				},
			},
		},
	},
}
