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
		keys = {
			{ "K", vim.lsp.buf.hover, desc = "Show documentation" },
			{ "H", function() vim.diagnostic.open_float { border = "rounded" } end, desc = "Show diagnostics" },
			{ "<C-k>", vim.lsp.buf.signature_help, desc = "Interactive signature help" },
			{ "<leader>a", vim.lsp.buf.code_action, desc = "Interactive list of code actions", mode = { "n", "v" } },
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
			require("neoconf").setup {}
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

			vim.api.nvim_create_autocmd("InsertEnter", { callback = function() vim.lsp.inlay_hint.enable(false) end })
			vim.api.nvim_create_autocmd(
				"InsertLeave",
				{ callback = function() vim.lsp.inlay_hint.enable(vim.b.inlay_hints_enabled or false) end }
			)

			map {
				{ "<leader>r", group = "refactor", icon = "" },
			}
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
				tools = { inlay_hints = { auto = false } },
				server = {
					standalone = false,
					on_attach = function(_, bufnr)
						map {
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

			map {
				{ "<leader>t", group = "tests", icon = "" },
			}
		end,
	},
}
