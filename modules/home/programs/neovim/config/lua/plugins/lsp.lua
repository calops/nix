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
			{ "K", vim.lsp.buf.hover, desc = "Show documentation" },
			{ "H", function() vim.diagnostic.open_float { border = "rounded" } end, desc = "Show diagnostics" },
			{ "<C-k>", vim.lsp.buf.signature_help, desc = "Interactive signature help" },
			{
				"<leader>i",
				function()
					vim.b.inlay_hints_enabled = not vim.b.inlay_hints_enabled
					vim.lsp.inlay_hint.enable(vim.b.inlay_hints_enabled or false)
				end,
				desc = "Toggle inlay hints for buffer",
			},

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
				automatic_installation = false,
				handlers = {
					function(server_name) require("lspconfig")[server_name].setup {} end,
				},
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
			lspconfig.lexical.setup {
				filetypes = { "elixir", "eelixir", "heex" },
				cmd = { "lexical" },
				root_dir = function(fname) return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or nil end,
			}

			utils.aucmd("InsertEnter", function() vim.lsp.inlay_hint.enable(false) end)
			utils.aucmd("InsertLeave", function() vim.lsp.inlay_hint.enable(vim.b.inlay_hints_enabled or false) end)

			utils.map {
				{ "<leader>r", group = "refactor", icon = "" },
			}
		end,
	},
	{
		"rachartier/tiny-code-action.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope.nvim" },
		},
		keys = {
			{
				"<leader>a",
				function() require("tiny-code-action").code_action() end,
				desc = "Interactive list of code actions",
			},
		},
		event = "LspAttach",
		opts = {
			backend = "vim", -- FIXME: delta is not rendering correctly
			backend_opts = {
				delta = {
					header_lines_to_remove = 4,
					args = { "--features", "nosidebyside" },
				},
			},
		},
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
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "wezterm-types", mods = { "wezterm" } },
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
		keys = {
			{ "<space>tt", function() require("neotest").run.run() end, desc = "Run closest test" },
			{
				"<space>tf",
				function() require("neotest").run.run(vim.fn.expand("%")) end,
				desc = "Run all tests in file",
			},
			{ "<space>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
			{ "<space>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle output" },
		},
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
