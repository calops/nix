local map = require("core.utils").map

return {
	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-media-files.nvim",
			"nvim-telescope/telescope-symbols.nvim",
			"Marskey/telescope-sg",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "prochri/telescope-all-recent.nvim", dependencies = { "kkharji/sqlite.lua" } },
		},
		cmd = "Telescope",
		lazy = true,
		keys = {
			{ "<C-p>", function() require("telescope.builtin").find_files() end, desc = "Find files" },
			{
				"<leader><Space>",
				function() require("telescope.builtin").grep_string() end,
				desc = "Grep word under cursor",
			},
			{
				"<leader>S",
				function() require("telescope.builtin").grep_string { search = "" } end,
				desc = "Fuzzy grep",
			},
			{ "<leader>s", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
			{ "<leader>b", function() require("telescope.builtin").buffers() end, desc = "Find buffer" },
			{ "<leader>e", function() require("telescope.builtin").symbols() end, desc = "Select symbol" },
			{ "<leader>R", function() require("telescope.builtin").resume() end, desc = "Resume selection" },
			{
				"<leader>s",
				function()
					vim.cmd('noau normal! "vy"')
					local text = vim.fn.getreg("v")
					vim.fn.setreg("v", {})
					require("telescope.builtin").grep_string { search = text }
				end,
				desc = "Grep current selection",
				mode = { "x", "v" },
			},
		},
		config = function()
			require("notify")
			local telescope = require("telescope")

			telescope.setup {
				defaults = {
					layout_strategy = "flex",
					layout_config = {
						flex = { flip_columns = 200 },
					},
					mappings = {
						i = {
							["<esc>"] = require("telescope.actions").close,
							["<C-T>"] = function() require("trouble.sources.telescope").open() end,
						},
						n = {
							["<C-T>"] = function() require("trouble.sources.telescope").open() end,
						},
					},
				},
			}

			telescope.load_extension("fzf")
			telescope.load_extension("notify")
			telescope.load_extension("media_files")
			telescope.load_extension("textcase")
			telescope.load_extension("yank_history")
			telescope.load_extension("persisted")
			telescope.load_extension("ast_grep")

			---@diagnostic disable-next-line: missing-fields
			require("telescope-all-recent").setup {
				default = { sorting = "frecency" },
				pickers = {
					live_grep = { disable = false },
					grep_string = { disable = false },
					yank_history = { disable = true },
				},
			}
		end,
	},
	-- File tree browser
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "<leader>nn", ":Neotree toggle reveal_force_cwd<cr>", desc = "Toggle file browser" },
			{ "<leader>ng", ":Neotree toggle git_status<cr>", desc = "Show git status" },
			{ "<leader>nb", ":Neotree toggle buffers<cr>", desc = "Show open buffers" },
		},
		init = function() map { "<leader>n", group = "file tree", icon = "" } end,
		opts = {
			popup_border_style = "rounded",
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
			source_selector = {
				winbar = true,
				statusline = false,
			},
			default_component_configs = {
				modified = {
					symbol = "",
				},
				git_status = {
					symbols = {
						unstaged = "",
					},
				},
			},
		},
	},
	-- Icons
	{
		"echasnovski/mini.icons",
		opts = {},
		lazy = true,
		specs = {
			{ "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				-- needed since it will be false when loading and mini will fail
				package.loaded["nvim-web-devicons"] = {}
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}
