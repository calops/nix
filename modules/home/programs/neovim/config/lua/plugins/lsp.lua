local map = require("core.utils").map

return {
	{
		"neovim/nvim-lspconfig",
		event = "BufRead",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"folke/neoconf.nvim",
		},
		init = function()
			map {
				K = { vim.lsp.buf.hover, "Show documentation" },
				H = { function() vim.diagnostic.open_float { border = "rounded" } end, "Show diagnostics" },
				["<C-k>"] = { vim.lsp.buf.signature_help, "Interactive signature help" },
				["<leader>r"] = {
					name = "refactor",
					n = { vim.lsp.buf.rename, "Interactive rename" },
					f = { vim.lsp.buf.format, "Format code" },
				},
				["<leader>a"] = { vim.lsp.buf.code_action, "Interactive list of code actions", mode = { "n", "v" } },
				["<leader>i"] = {
					function()
						---@diagnostic disable-next-line: inject-field
						vim.b.inlay_hints_enabled = not vim.b.inlay_hints_enabled
						vim.lsp.inlay_hint.enable(vim.b.inlay_hints_enabled or false)
					end,
					"Toggle inlay hints for buffer",
				},
			}
		end,
		config = function()
			require("neoconf").setup {}
			require("mason").setup { ui = { border = "rounded" } }
			require("mason-lspconfig").setup {
				automatic_installation = false,
				handlers = { function(server_name) require("lspconfig")[server_name].setup {} end },
			}

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup {}
			lspconfig.nil_ls.setup {}
			lspconfig.nixd.setup {
				on_init = function(client, _)
					-- Turn off semantic tokens until they're more consistent
					client.server_capabilities.semanticTokensProvider = nil
				end,
			}

			vim.api.nvim_create_autocmd("InsertEnter", { callback = function() vim.lsp.inlay_hint.enable(false) end })
			vim.api.nvim_create_autocmd(
				"InsertLeave",
				{ callback = function() vim.lsp.inlay_hint.enable(vim.b.inlay_hints_enabled or false) end }
			)
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},
	-- Rust-specific utilities and LSP configurations
	{
		"mrcjkb/rustaceanvim",
		ft = "rust",
		init = function()
			vim.g.rustaceanvim = {
				tools = {
					inlay_hints = {
						auto = false,
					},
				},
				server = {
					standalone = false,
					on_attach = function(_, bufnr)
						map {
							K = { ":RustLsp hover range<CR>", "Hover information", buffer = bufnr, mode = "x" },
						}
					end,
					["rust-analyzer"] = {
						semanticHighlighting = {
							["punctuation.enable"] = true,
							["punctuation.separate.macro.bang"] = true,
						},
						diagnostics = {
							enable = true,
							disabled = { "unresolved-method", "unresolved-field" },
							experimental = { enable = true },
						},
						assist = {
							emitMustUse = true,
						},
						procMacro = {
							enable = true,
						},
					},
				},
			}
		end,
	},
	-- Tests
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"jfpedroza/neotest-elixir",
		},
		cmd = "Neotest",
		init = function()
			map {
				["<space>t"] = {
					name = "tests",
					t = { function() require("neotest").run.run() end, "Run closest test" },
					f = { function() require("neotest").run.run(vim.fn.expand("%")) end, "Run all tests in file" },
					s = { function() require("neotest").summary.toggle() end, "Toggle summary" },
					o = { function() require("neotest").output_panel.toggle() end, "Toggle output" },
				},
			}
		end,
		config = function()
			require("neotest").setup {
				adapters = {
					require("rustaceanvim.neotest"),
					require("neotest-elixir"),
				},
			}
		end,
	},
}
