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
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			{
				"prochri/telescope-all-recent.nvim",
				dependencies = { "kkharji/sqlite.lua" },
			},
		},
		cmd = "Telescope",
		lazy = true,
		init = function()
			map {
				["<C-p>"] = { function() require("telescope.builtin").find_files() end, "Find files" },
				["<leader>"] = {
					["<Space>"] = {
						function() require("telescope.builtin").grep_string() end,
						"Grep word under cursor",
					},
					S = { function() require("telescope.builtin").grep_string { search = "" } end, "Fuzzy grep" },
					s = { function() require("telescope.builtin").live_grep() end, "Live grep" },
					b = { function() require("telescope.builtin").buffers() end, "Find buffer" },
					e = { function() require("telescope.builtin").symbols() end, "Select symbol" },
					R = { function() require("telescope.builtin").resume() end, "Resume selection" },
				},
			}
			map({
				["<leader>s"] = {
					function()
						vim.cmd('noau normal! "vy"')
						local text = vim.fn.getreg("v")
						vim.fn.setreg("v", {})
						-- return #text > 0 and text or ""
						require("telescope.builtin").grep_string { search = text }
					end,
					"Grep current selection",
				},
			}, { mode = { "x", "v" } })
		end,
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
							["<C-t>"] = function() require("trouble.sources.telescope").open() end,
						},
						n = {
							["<C-t>"] = function() require("trouble.sources.telescope").open() end,
						},
					},
				},
			}

			telescope.load_extension("fzf")
			telescope.load_extension("notify")
			telescope.load_extension("media_files")
			telescope.load_extension("ast_grep")
			telescope.load_extension("textcase")
			telescope.load_extension("yank_history")
			telescope.load_extension("persisted")
			telescope.load_extension("ast_grep")

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
			"kyazdani42/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		init = function()
			map {
				["<leader>n"] = {
					name = "file tree",
					n = { ":Neotree toggle reveal_force_cwd<cr>", "Toggle file browser" },
					g = { ":Neotree toggle git_status<cr>", "Show git status" },
					b = { ":Neotree toggle buffers<cr>", "Show open buffers" },
				},
			}
		end,
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
}
