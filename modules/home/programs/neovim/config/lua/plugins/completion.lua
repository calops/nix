return {
	-- Auto-completion
	{
		"hrsh7th/nvim-cmp",
		event = "BufRead",
		dependencies = {
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-git",
			"hrsh7th/cmp-emoji",
			"davidsierradz/cmp-conventionalcommits",
			"chrisgrieser/cmp-nerdfont",
			"chrisgrieser/cmp_yanky",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup {
				mapping = cmp.mapping.preset.insert {
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.abort(),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm { select = false },
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
					{ name = "path" },
					{ name = "nerdfont" },
					{ name = "emoji" },
					{ name = "otter" },
					{ name = "lazydev", group_index = 0 },
				}, {
					{ name = "buffer" },
					{ name = "cmp_yanky" },
				}),
				formatting = {
					format = require("lspkind").cmp_format(),
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
			}

			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources(
					{ { name = "conventionalcommits" }, { name = "cmp_git" } },
					{ { name = "buffer" } }
				),
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
			require("cmp_git").setup()
		end,
	},
}
