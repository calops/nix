local map = require("core.utils").map

return {
	{
		"VonHeikemen/lsp-zero.nvim",
		lazy = false,
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
			"onsails/lspkind.nvim",
			"folke/neodev.nvim",
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
						vim.lsp.inlay_hint.enable(0, vim.b.inlay_hints_enabled or false)
					end,
					"Toggle inlay hints for buffer",
				},
			}

			vim.api.nvim_create_autocmd(
				"InsertEnter",
				{ callback = function() vim.lsp.inlay_hint.enable(0, false) end }
			)

			vim.api.nvim_create_autocmd(
				"InsertLeave",
				{ callback = function() vim.lsp.inlay_hint.enable(0, vim.b.inlay_hints_enabled or false) end }
			)

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
		end,
		config = function()
			require("neodev")
			require("neoconf")

			local lsp_zero = require("lsp-zero")

			require("mason").setup { ui = { border = "rounded" } }
			require("mason-lspconfig").setup {
				automatic_installation = false,
				handlers = {
					lsp_zero.default_setup,
					vtsls = function()
						require("lspconfig").vtsls.setup {
							settings = {
								typescript = {
									inlayHints = {
										enumMemberValues = { enabled = true },
										functionLikeReturnTypes = { enabled = true },
										parameterNames = { enabled = "all" },
										parameterTypes = { enabled = false },
										propertyDeclarationTypes = { enabled = true },
										variableTypes = { enabled = true },
									},
								},
							},
						}
					end,
				},
			}

			-- Installed by nix
			local lspconfig = require("lspconfig")
			lspconfig.nixd.setup {}
			lspconfig.lua_ls.setup {
				settings = {
					Lua = {
						format = { enable = false },
						hint = { enable = true },
					},
				},
			}
		end,
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
							K = { "RustLsp hover range", "Hover information", buffer = bufnr, mode = "x" },
						}
					end,
					["rust-analyzer"] = {
						semanticHighlighting = {
							["punctuation.enable"] = true,
							["punctuation.separate.macro.bang"] = true,
						},
						diagnostics = {
							enable = true,
							-- disabled = { "unresolved-method", "unresolved-field" },
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
	-- Neovim lua LSP utilities
	{
		"folke/neodev.nvim",
		lazy = false,
		enabled = true,
		opts = {
			pathStrict = false,
			-- Always load nvim plugins for lua_ls, this is a temporary hack
			-- FIXME: this hurts performance, should be fixed upstream
			override = function(_, library)
				library.enabled = true
				library.plugins = true
			end,
		},
	},
	-- AI, baby
	{
		"zbirenbaum/copilot.lua",
		event = "VeryLazy",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<M-CR>",
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					next = "<M-Right>",
					prev = "<M-Left>",
					dismiss = "<C-:>",
				},
			},
			filetypes = {
				yaml = true,
				gitcommit = true,
				markdown = true,
			},
		},
	},
	-- LSP within TS injections
	{
		"jmbuhr/otter.nvim",
		init = function()
			vim.api.nvim_create_user_command(
				"Otter",
				function(cmd) require("otter").activate(cmd.fargs) end,
				{ nargs = "+" }
			)
		end,
		opts = {},
	},
	-- Tests
	{
		"nvim-neotest/neotest",
		config = function()
			require("neotest").setup {
				adapters = {
					require("rustaceanvim.neotest"),
				},
			}
		end,
	},
}
