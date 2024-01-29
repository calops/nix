local map = require("core.utils").map

return {
	-- Show icons for LSP completions
	{
		"onsails/lspkind.nvim",
		event = "LspAttach",
	},
	-- Language servers and utilities orchestrator
	{
		"williamboman/mason.nvim",
		lazy = false,
		priority = 2,
		config = function()
			require("mason").setup {
				ui = { border = "rounded" },
			}
			require("mason-lspconfig")
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true,
		config = function()
			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup { automatic_installation = false }
			mason_lspconfig.setup_handlers {
				function(server_name) -- automatically setup server by default
					lspconfig[server_name].setup {}
				end,
				rust_analyzer = nil, -- handled entirely by rustaceanvim, and installed by nix
				lua_ls = nil,
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		init = function()
			vim.g.inlay_hints_enabled = true

			map {
				K = { vim.lsp.buf.hover, "Show documentation" },
				H = {
					function() vim.diagnostic.open_float { border = "rounded" } end,
					"Show diagnostics",
				},
				["<C-k>"] = { vim.lsp.buf.signature_help, "Interactive signature help" },
				["<leader>r"] = {
					name = "refactor",
					n = { vim.lsp.buf.rename, "Interactive rename" },
					f = { vim.lsp.buf.format, "Format code" },
				},
				["<leader>a"] = {
					vim.lsp.buf.code_action,
					"Interactive list of code actions",
					mode = { "n", "v" },
				},
				["<leader>i"] = {
					function()
						vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled
						vim.lsp.inlay_hint.enable(0, vim.g.inlay_hints_enabled)
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
				{ callback = function() vim.lsp.inlay_hint.enable(0, vim.g.inlay_hints_enabled) end }
			)

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
		end,
		config = function()
			require("neodev")
			require("neoconf")

			local lspconfig = require("lspconfig")
			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(bufnr, vim.g.inlay_hints_enabled)
					end
				end,
			})

			-- Installed by nix
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
		ft = "lua",
		priority = 1000,
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
}
