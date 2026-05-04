return {
	{
		"milanglacier/minuet-ai.nvim",
		event = "InsertEnter",
		opts = {
			provider = "openai_compatible",
			request_timeout = 2.5,
			throttle = 200,
			debounce = 200,
			virtualtext = {
				auto_trigger_ft = {},
				keymap = {
					accept = "<M-Cr>",
					accept_line = "<M-l>",
					accept_n_lines = "<M-z>",
					prev = "<M-[>",
					next = "<M-space>",
					dismiss = "<M-e>",
				},
			},
			provider_options = {
				openai_compatible = {
					api_key = function()
						local handle = io.popen('op-credential --raw "OpenCode GO" 2>/dev/null')
						if handle then
							local result = handle:read("*a")
							handle:close()
							return (result or ""):gsub("%s+$", "")
						end
						return ""
					end,
					end_point = "https://opencode.ai/zen/go/v1/chat/completions",
					model = "deepseek-v4-flash",
					name = "Opencode",
					optional = {
						max_tokens = 56,
						top_p = 0.9,
						thinking = { type = "disabled" },
					},
				},
			},
		},
	},
	{
		"folke/sidekick.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<c-;>",
				function() require("sidekick.cli").toggle { focus = true } end,
				desc = "Sidekick Toggle CLI",
				mode = { "n", "v", "t" },
			},
			{
				"<leader>ap",
				function() require("sidekick.cli").prompt() end,
				desc = "Sidekick Ask Prompt",
				mode = { "n", "v" },
			},
			{
				"<leader>at",
				function() require("sidekick.cli").send { msg = "{this}" } end,
				mode = { "x", "n" },
				desc = "Send this",
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
