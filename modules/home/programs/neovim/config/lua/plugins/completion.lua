return {
	-- Auto-completion
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = { "rafamadriz/friendly-snippets" },
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
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					codecompanion = { "codecompanion" },
					lua = { "lsp", "path", "lazydev", "snippets", "buffer" },
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						fallbacks = { "lsp" },
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
					border = vim.g.floating_border,
					max_height = 15,
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 50,
					window = {
						border = vim.g.floating_border,
						max_width = 80,
					},
				},
			},
			signature = {
				enabled = true,
				window = { border = vim.g.floating_border },
			},
		},
	},
}
