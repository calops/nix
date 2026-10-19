return {
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
					keys = {
						shift_enter = {
							"<S-CR>",
							function(terminal)
								-- Send kitty keyboard protocol shift+enter directly to the job
								vim.api.nvim_chan_send(terminal.job, "\27[13;2u")
							end,
							mode = "t",
							desc = "send shift+enter to terminal",
						},
					},
				},
				tools = {
					oh_my_pi = {
						cmd = { "omp" },
						is_proc = "\\<omp\\>",
						native_scroll = false,
					},
				},
			},
		},
	},
}
