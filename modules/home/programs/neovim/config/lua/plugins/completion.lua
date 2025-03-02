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
			cmdline = { completion = { ghost_text = { enabled = false } } },
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						fallbacks = { "lsp" },
					},
				},
			},
			keymap = {
				preset = "default",
				["<Cr>"] = { "accept", "fallback" },
				["<C-y>"] = { "accept", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<C-j>"] = { "scroll_documentation_down", "fallback" },
				["<C-k>"] = { "scroll_documentation_up", "fallback" },
			},
			completion = {
				ghost_text = { enabled = false },
				list = {
					selection = {
						preselect = false,
						auto_insert = function(ctx) return ctx.mode == "cmdline" end,
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
