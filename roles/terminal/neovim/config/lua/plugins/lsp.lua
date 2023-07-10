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
				function(server_name) -- default handler (optional)
					lspconfig[server_name].setup {}
				end,
				rust_analyzer = nil, -- handled entirely by rust-tools.nvim, and installed by nix
				lua_ls = function()
					lspconfig.lua_ls.setup {
						settings = {
							Lua = {
								format = { enable = false },
								hint = { enable = true },
								runtime = { version = "LuaJIT" },
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					}
				end,
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		init = function()
			map {
				K = { vim.lsp.buf.hover, "Show documentation" },
				H = {
					function() vim.diagnostic.open_float { border = "rounded" } end,
					"Show diagnostics",
				},
				["<C-k>"] = { vim.lsp.buf.signature_help, "Interactive signature help" },
				["<space>f"] = { vim.lsp.buf.format, "Format code" },
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
					function() vim.lsp.buf.inlay_hint(0) end,
					"Toggle inlay hints for buffer",
				},
			}
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

			-- Auto format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.rs,*.nix,*.lua",
				callback = function()
					for _, client in ipairs(vim.lsp.get_active_clients()) do
						if client.attached_buffers[vim.api.nvim_get_current_buf()] then
							vim.lsp.buf.format()
							return
						end
					end
				end,
			})
		end,
		config = function()
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
						vim.lsp.buf.inlay_hint(bufnr, true)
					end
				end,
			})

			-- Installed by nix
			lspconfig.nixd.setup {}
		end,
	},
	-- LSP bridge for non-LSP utilities
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "BufRead",
		config = function()
			local nls = require("null-ls")
			nls.setup {
				sources = {
					nls.builtins.formatting.stylua,
					nls.builtins.diagnostics.buf,
					nls.builtins.formatting.npm_groovy_lint,
					nls.builtins.formatting.alejandra,
					nls.builtins.formatting.sqlfluff.with {
						extraArgs = { "--dialect", "postgres" },
					},
				},
			}
		end,
	},
	-- Rust-specific utilities and LSP configurations
	{
		"simrat39/rust-tools.nvim",
		event = { "BufReadPost *.rs" },
		opts = {
			tools = {
				inlay_hints = {
					auto = false,
				},
			},
			server = {
				standalone = false,
				on_attach = function(_, bufnr)
					local rt = require("rust-tools")
					map {
						["<C-h>"] = { rt.hover_actions.hover_actions, "Hover actions", buffer = bufnr },
						K = { rt.hover_range.hover_range, "Hover information", buffer = bufnr, mode = "x" },
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
						experimental = { enable = false },
					},
					assist = {
						emitMustUse = true,
					},
					procMacro = {
						enable = true,
					},
				},
			},
		},
	},
	-- Neovim lua LSP utilities
	{
		"folke/neodev.nvim",
		ft = "lua",
		config = true,
	},
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
			},
		},
	},
}
