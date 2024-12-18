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
			{ "<leader>rn", vim.lsp.buf.rename, desc = "Interactive rename" },
			{ "<leader>rf", vim.lsp.buf.format, desc = "Format code" },
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
				handlers = {
					function(server_name) require("lspconfig")[server_name].setup {} end,
				},
			}

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup {}
			lspconfig.nil_ls.setup {}
			lspconfig.ruff.setup {}
			lspconfig.pyright.setup {}
			lspconfig.nixd.setup {
				on_init = function(client, _)
					-- Turn off semantic tokens until they're more consistent
					client.server_capabilities.semanticTokensProvider = nil
				end,
			}

			utils.map {
				{ "<leader>r", group = "refactor", icon = "" },
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
	-- Elixir-specific utilities and LSP configurations
	{
		"elixir-tools/elixir-tools.nvim",
		version = "*",
		ft = "elixir",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local elixir = require("elixir")
			local elixirls = require("elixir.elixirls")

			elixir.setup {
				nextls = {
					enable = true,
					init_options = { experimental = { completions = { enable = true } } },
				},
				projectionist = { enable = false },
				elixirls = {
					enable = true,
					cmd = "elixir-ls",
					settings = elixirls.settings {
						dialyzerEnabled = true,
						enableTestLenses = false,
						suggestSpecs = true,
					},
					on_attach = function(client)
						client.server_capabilities.completionProvider = nil
						utils.map {
							{ "<spaceP>", ":ElixirFromPipe<cr>", desc = "Convert from pipe" },
							{ "<space>p", ":ElixirToPipe<cr>", desc = "Convert to pipe" },
							{ "<space>em", ":ElixirExpandMacro<cr>", desc = "Expand macro", mode = "v" },
						}
					end,
				},
			}

			local lspconfig = require("lspconfig")
			lspconfig.lexical.setup {
				filetypes = { "elixir", "eelixir", "heex" },
				cmd = { "lexical" },
				root_dir = function(fname) return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or nil end,
				on_attach = function(client) client.server_capabilities.completionProvider = nil end,
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

			utils.map {
				{ "<leader>t", group = "tests", icon = "" },
			}
		end,
	},
}
