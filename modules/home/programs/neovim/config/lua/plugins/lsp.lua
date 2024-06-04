local map = require("core.utils").map

local lsp_init_function = function()
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
end

local lsp_config_function = function()
	require("neoconf").setup {}
	local lsp_zero = require("lsp-zero")
	require("mason").setup { ui = { border = "rounded" } }
	require("mason-lspconfig").setup {
		automatic_installation = false,
		handlers = { lsp_zero.default_setup },
	}

	local lspconfig = require("lspconfig")
	lspconfig.vtsls.setup {
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
	lspconfig.nil_ls.setup {}
	lspconfig.nixd.setup {
		on_init = function(client, _)
			-- Turn off semantic tokens until they're more consistent
			client.server_capabilities.semanticTokensProvider = nil
		end,
	}
	lspconfig.lua_ls.setup {
		settings = {
			Lua = {
				format = { enable = false },
				hint = { enable = true },
			},
		},
	}
	lspconfig.lexical.setup {
		filetypes = { "elixir", "eelixir", "heex" },
		cmd = { "lexical" },
		root_dir = function(fname) return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or nil end,
	}

	vim.api.nvim_create_autocmd("InsertEnter", { callback = function() vim.lsp.inlay_hint.enable(false) end })
	vim.api.nvim_create_autocmd(
		"InsertLeave",
		{ callback = function() vim.lsp.inlay_hint.enable(vim.b.inlay_hints_enabled or false) end }
	)

	local handlers = vim.lsp.handlers
	handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, { border = "rounded" })
	handlers["textDocument/signatureHelp"] = vim.lsp.with(handlers.signature_help, { border = "rounded" })
end

return {
	{
		"VonHeikemen/lsp-zero.nvim",
		event = "BufRead",
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
			"onsails/lspkind.nvim",
			"folke/neoconf.nvim",
		},
		init = lsp_init_function,
		config = lsp_config_function,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
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
	-- LSP within TS injections
	{
		"jmbuhr/otter.nvim",
		cmd = "Otter",
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
		dependencies = {
			"nvim-neotest/nvim-nio",
		},
		cmd = "Neotest",
		config = function()
			require("neotest").setup {
				adapters = {
					require("rustaceanvim.neotest"),
				},
			}
		end,
	},
}
