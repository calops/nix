return {
	-- Auto-completion
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		dependencies = "rafamadriz/friendly-snippets",
		version = "v0.*", -- use a version tag to fetch the prebuilt binary
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
				},
				signature_help = { border = "rounded" },
				documentation = {
					border = "rounded",
					auto_show_delay_ms = 50,
					max_width = 80,
				},
			},
		},
	},
	-- Only used for cmdline completion, TODO: remove whonce blink supports this (contribute myself?)
	{
		"iguanacucumber/magazine.nvim",
		event = "VeryLazy",
		dependencies = "hrsh7th/cmp-cmdline",
		config = function()
			local cmp = require("cmp")
			local window_config = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			}

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
				window = window_config,
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				window = window_config,
			})
		end,
	},
}
