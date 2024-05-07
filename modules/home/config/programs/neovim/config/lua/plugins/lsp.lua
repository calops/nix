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
	require("neodev").setup {
		pathStrict = false,
		-- Always load nvim plugins for lua_ls, this is a temporary hack
		-- FIXME: this hurts performance, should be fixed upstream
		override = function(_, library)
			library.enabled = true
			library.plugins = true
			library.types = true
			library.runtime = true
		end,
	}

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
		root_dir = function(fname)
			return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or vim.loop.os_homedir()
		end,
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
			"folke/neodev.nvim",
			"folke/neoconf.nvim",
		},
		init = lsp_init_function,
		config = lsp_config_function,
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
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		lazy = true,
		opts = {
			question_header = "##   User ――――――――――――――――――――――",
			answer_header = "##   Copilot ―――――――――――――――――――",
			error_header = "##   Error ―――――――――――――――――――――",
			separator = "",
			show_folds = false,
			context = "buffer",
			window = {
				layout = "vertical",
				width = 120,
				height = 0.8,
				relative = "editor",
				border = "rounded",
				zindex = 50,
			},
		},
		init = function()
			local function pick_with_selection(selection)
				return function()
					local actions = require("CopilotChat.actions")
					actions.pick(actions.prompt_actions { selection = require("CopilotChat.select")[selection] })
				end
			end
			map({
				["<leader>c"] = {
					name = "copilot",
					c = { function() require("CopilotChat").toggle() end, "Toggle Copilot Chat" },
					b = { pick_with_selection("buffer"), "Actions on buffer" },
					a = { pick_with_selection("buffers"), "Actions on all buffers" },
					s = { pick_with_selection("visual"), "Actions on selection" },
				},
			}, { mode = { "n", "v", "x" } })
		end,
		config = function(opts)
			require("CopilotChat").setup(opts)
			require("core.utils").make_sidebar(
				"copilot-chat",
				function() return vim.fn.bufname() == "copilot-chat" and vim.fn.win_gettype() ~= "popup" end
			)
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
