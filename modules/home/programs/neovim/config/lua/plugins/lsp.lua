local utils = require("core.utils")

return {
	{
		"neovim/nvim-lspconfig",
		event = "BufRead",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"folke/neoconf.nvim",
		},
		keys = {
			{ "K", require("noice.lsp").hover, desc = "Show documentation" },
			{ "H", function() vim.diagnostic.open_float { border = "rounded" } end, desc = "Show diagnostics" },
			{ "<C-k>", vim.lsp.buf.signature_help, desc = "Interactive signature help" },
			{ "<space>n", vim.lsp.buf.rename, desc = "Interactive rename" },
			{ "<space>F", vim.lsp.buf.format, desc = "Format code with LSP" },
			{ "<space>a", vim.lsp.buf.code_action, desc = "Code actions" },
			{
				"<space>d",
				function() vim.diagnostic.jump { count = 1, float = { border = "rounded" } } end,
				desc = "Jump to next diagnostic",
			},
		},
		config = function()
			require("neoconf").setup {
				plugins = {
					jsonls = {
						enabled = true,
						configured_servers_only = false,
					},
				},
			}
			require("mason").setup { ui = { border = "rounded" } }

			require("mason-lspconfig").setup {
				ensure_installed = {},
				automatic_installation = false,
			}

			vim.lsp.enable {
				-- Lua
				"lua_ls",

				-- Python
				"ruff",
				"pyright",

				-- JavaScript/TypeScript
				"vtsls",

				-- Fish
				"fish_lsp",

				-- Nix
				"nil_ls",
				"nixd",

				-- Elixir
				"lexical",
				"elixirls",
				"nextls",
			}
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		dependencies = {
			"justinsgithub/wezterm-types",
			"Bilal2453/luvit-meta",
		},
		opts = {
			library = {
				"snacks.nvim",
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "wezterm-types", mods = { "wezterm" } },
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
			"jfpedroza/neotest-elixir",
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
					require("neotest-elixir"),
				},
			}
		end,
	},

	-- Database explorer
	{
		"xemptuous/sqlua.nvim",
		cmd = "SQLua",
		opts = {},
	},
}
