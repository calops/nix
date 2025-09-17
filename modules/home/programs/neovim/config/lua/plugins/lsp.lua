local utils = require("core.utils")

return {
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		keys = {
			{
				"H",
				function() vim.diagnostic.open_float { border = vim.g.floating_border } end,
				desc = "Show diagnostics",
			},
			{ "<space>n", vim.lsp.buf.rename, desc = "Interactive rename" },
			{ "<space>F", vim.lsp.buf.format, desc = "Format code with LSP" },
			{
				"<C-s>",
				function() vim.lsp.buf.signature_help { border = vim.g.floating_border } end,
				desc = "Interactive LSP signature help",
			},
			{
				"<space>d",
				function() vim.diagnostic.jump { count = 1, float = { border = vim.g.floating_border } } end,
				desc = "Jump to next diagnostic",
			},
		},
		config = function()
			require("mason").setup { ui = { border = vim.g.floating_border } }
			require("mason-lspconfig").setup {
				ensure_installed = {},
				automatic_installation = false,
			}

			vim.lsp.enable {
				-- Lua
				"lua_ls",

				-- JavaScript/TypeScript
				"vtsls",

				-- Fish
				"fish_lsp",

				-- Nix
				"nil_ls",
				"nixd",

				-- QML
				"qmlls",
			}

			vim.lsp.config("*", {
				on_attach = function(_, bufnr) vim.lsp.document_color.enable(true, bufnr, { style = "virtual" }) end,
			})

			vim.lsp.inline_completion.enable(true)
			vim.lsp.on_type_formatting.enable(true)
		end,
	},

	{
		"rachartier/tiny-code-action.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "LspAttach",
		keys = {
			{
				"<space>a",
				function() require("tiny-code-action").code_action {} end,
				desc = "Code actions",
			},
		},
		opts = {
			backend = "delta",
			picker = "snacks",
			backend_opts = {
				delta = {
					args = {
						"--features=catppuccin",
					},
				},
			},
		},
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		dependencies = {
			"Bilal2453/luvit-meta",
		},
		opts = {
			library = {
				"snacks.nvim",
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "~/.local/share/lua", mods = { "palette" } },
			},
		},
	},

	-- Rust-specific utilities and LSP configurations
	{
		"mrcjkb/rustaceanvim",
		ft = "rust",
		init = function()
			vim.g.rustaceanvim = {
				tools = { inlay_hints = { auto = false } },
				server = {
					standalone = false,
					on_attach = function(_, bufnr)
						utils.map {
							{
								"K",
								function() vim.cmd(":RustLsp hover range<CR>") end,
								desc = "Hover information",
								buffer = bufnr,
								mode = "x",
							},
						}
					end,
				},
			}
		end,
	},

	-- Tests
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-neotest/neotest-python",
		},
		cmd = "Neotest",
		keys = function()
			utils.map {
				{ "<space>t", group = "tests", icon = "" },
			}
			return {
				{ "<space>tt", function() require("neotest").run.run() end, desc = "Run closest test" },
				{
					"<space>tf",
					function() require("neotest").run.run(vim.fn.expand("%")) end,
					desc = "Run all tests in file",
				},
				{ "<space>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
				{ "<space>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle output" },
			}
		end,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("neotest").setup {
				adapters = {
					require("rustaceanvim.neotest"),
					require("neotest-python"),
				},
				---@diagnostic disable-next-line: missing-fields
				floating = { border = vim.g.floating_border },
			}
		end,
	},

	-- Database explorer
	{
		"xemptuous/sqlua.nvim",
		cmd = "SQLua",
		opts = {},
	},

	{
		"jmbuhr/otter.nvim",
		opts = {},
	},
}
