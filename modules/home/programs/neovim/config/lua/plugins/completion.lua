local function test(a, b, c) end

return {
	-- Auto-completion
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = "rafamadriz/friendly-snippets",
		build = "cargo build --release",

		opts = {
			highlight = { use_nvim_cmp_as_default = true },
			trigger = { signature_help = { enabled = true } },
			sources = {
				completion = { enabled_providers = { "lsp", "path", "snippets", "buffer", "lazydev" } },
				providers = {
					lsp = {
						name = "lsp",
						fallback_for = { "lazydev" },
					},
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
				},
			},
			keymap = {
				---@diagnostic disable-next-line: assign-type-mismatch
				preset = "default",
				["<Cr>"] = { "accept", "fallback" },
				["<C-y>"] = { "accept", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-j>"] = { "scroll_documentation_down", "fallback" },
				["<C-k>"] = { "scroll_documentation_up", "fallback" },
			},
			completion = {
				list = { selection = "manual" },
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
