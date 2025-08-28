return {
	-- Auto-completion
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"Kaiser-Yang/blink-cmp-avante",
		},
		build = "cargo build --release",
		opts_extend = { "sources.default" },

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			appearance = { use_nvim_cmp_as_default = true },
			cmdline = {
				completion = {
					list = {
						selection = {
							preselect = false,
							auto_insert = true,
						},
					},
					menu = {
						auto_show = true,
						preselect = false,
					},
					ghost_text = { enabled = false },
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				per_filetype = {
					codecompanion = { "codecompanion" },
					AvanteInput = { "avante" },
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						fallbacks = { "lsp" },
					},
					avante = {
						module = "blink-cmp-avante",
						name = "Avante",
					},
				},
			},
			keymap = {
				preset = "enter",
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
			},
			completion = {
				ghost_text = { enabled = false },
				list = {
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},
				menu = {
					border = "rounded",
					max_height = 15,
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 50,
					window = {
						border = "rounded",
						max_width = 80,
					},
				},
			},
			signature = {
				enabled = true,
				window = { border = "rounded" },
			},
		},
	},
}
