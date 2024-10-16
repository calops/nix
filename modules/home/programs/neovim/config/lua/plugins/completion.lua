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
			keymap = {
				accept = "<Cr>",
				select_prev = { "<S-Tab>", "<Up>" },
				select_next = { "<Tab>", "<Down>" },
				scroll_documentation_down = "<C-j>",
				scroll_documentation_up = "<C-k>",
			},
			windows = {
				autocomplete = {
					border = "rounded",
					max_height = 15,
					preselect = false,
				},
				signature_help = { border = "rounded" },
				documentation = {
					border = "rounded",
					auto_show = true,
					auto_show_delay_ms = 50,
					max_width = 80,
				},
			},
		},
	},
}
