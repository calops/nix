local core_utils = require("core.utils")
local utils = require("plugins.ui.utils")
local map = core_utils.map

return {
	-- TUI
	{
		"rebelot/heirline.nvim",
		lazy = false,
		config = function()
			require("catppuccin")

			vim.o.signcolumn = "no"
			vim.o.foldcolumn = "0"

			require("heirline").setup {
				statuscolumn = require("plugins.ui.statuscolumn"),
				tabline = require("plugins.ui.tabline"),
				-- statusline = require('plugins.ui.statusline'),
			}

			local function new_tab()
				vim.cmd([[
                    let view = winsaveview()
                    tabedit %
                    call winrestview(view)
                ]])
			end

			map {
				["<C-t>"] = { new_tab, "Open current buffer in new tab" },
				["<C-g>"] = { ":tabclose<CR>", "Close current tab" },
				["<C-Tab>"] = { ":tabnext<CR>", "View next tab" },
				["<C-S-Tab>"] = { ":tabprevious<CR>", "View previous tab" },
			}
		end,
	},
	require("plugins.ui.windowline"),
	{
		"Bekaboo/dropbar.nvim",
		event = "UIEnter",
		version = "*",
		enabled = false,
		opts = {
			menu = {
				win_configs = {
					border = "rounded",
				},
			},
		},
	},
	-- Colorful modes
	{
		"mvllow/modes.nvim",
		event = "VeryLazy",
		config = true,
	},
	-- CMD line replacement and other UI niceties
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		enabled = true,
		lazy = false,
		init = function() map { ["<leader><leader>"] = { ":noh<CR>", "Hide search highlights" } } end,
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = false,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			views = {
				messages = { backend = "popup" },
			},
			popupmenu = { enabled = true, backend = "nui" },
			routes = {
				{
					view = "notify",
					filter = { event = "msg_show", find = '"*"*lines --*%--' },
					opts = { skip = true },
				},
			},
		},
	},
	-- IDE panels
	{
		"ldelossa/nvim-ide",
		cmd = "Workspace",
		init = function()
			map {
				["<leader>w"] = {
					name = "ide",
					l = { ":Workspace LeftPanelToggle<CR>", "Toggle git panels" },
					r = { ":Workspace RightPanelToggle<CR>", "Toggle IDE panels" },
				},
			}
		end,
		opts = {
			workspaces = {
				auto_open = "none",
			},
			panel_sizes = {
				left = 60,
				right = 60,
				bottom = 15,
			},
		},
	},
	-- Better select dialog
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			input = { enabled = false },
			select = { enabled = true },
		},
	},
	-- Context-aware indentation lines
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		main = "ibl",
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = { show_start = false },
		},
	},
	-- Notification handler
	{
		"rcarriga/nvim-notify",
		lazy = false,
		opts = {
			top_down = true,
			max_width = 100,
		},
	},
	-- Keymaps cheat sheet and tooltips
	{
		"folke/which-key.nvim",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 150
		end,
		opts = {
			window = {
				border = "rounded",
				position = "bottom",
				margin = { 10, 10, 2, 10 },
			},
		},
	},
	{
		"echasnovski/mini.hipatterns",
		event = "VeryLazy",
		config = function()
			local hipatterns = require("mini.hipatterns")
			local palette = utils.palette()
			local palette_patterns = {}
			local palette_highlights = {}

			for name, color in pairs(palette) do
				palette_patterns[name] = {
					pattern = "%f[%w]palette[.]()" .. name .. "()%f[%W]",
					group = "",
					extmark_opts = {
						virt_text_pos = "inline",
						virt_text = { { " ", "HiPatternsPalette_" .. name } },
					},
				}
				palette_highlights["HiPatternsPalette_" .. name] = { fg = color }
			end

			local function gen_palette_colors()
				return {
					pattern = function(bufnr)
						if vim.api.nvim_buf_get_name(bufnr):match("theme.lua$") then
							return "utils[.]%w*[(]palette[.].*, %d[.]%d+[)]"
						end
						return nil
					end,
					group = "",
					extmark_opts = function(_, _, data)
						local func, base_color, ratio =
							data.full_match:match("utils[.](%w*)[(]palette[.](.*), (%d[.]%d+)[)]")
						local group_name = "HiPatternsPalette_"
							.. base_color
							.. "_"
							.. func
							.. "_"
							.. ratio:gsub("%.", "_")
						base_color = palette[base_color]
						if vim.fn.hlexists(group_name) == 0 then
							require("catppuccin.lib.highlighter").syntax {
								[group_name] = {
									fg = utils[func](base_color, tonumber(ratio)),
								},
							}
						end

						return {
							virt_text_pos = "inline",
							virt_text = { { " ", group_name } },
						}
					end,
				}
			end

			local function gen_group_colors()
				return {
					pattern = function(bufnr)
						if vim.api.nvim_buf_get_name(bufnr):match("theme.lua$") then
							return "()[^	 ].*() = {.*palette.*}"
						end
						return nil
					end,
					group = function(_, _, data)
						local group, body = data.full_match:match("([^{]*) = ({.*})$")
						group = group:gsub('[]"[]+', "")
						local group_name = "HiPatternsGroup_" .. group
						local group_def = loadstring([[
							local utils = require("plugins.ui.utils")
							local palette = utils.palette()
							return ]] .. body)
						-- The group name isn't fully descriptive of what's inside, so we need to redefine it each time
						require("catppuccin.lib.highlighter").syntax {
							[group_name] = group_def and group_def() or nil,
						}
						return group_name
					end,
				}
			end

			require("catppuccin.lib.highlighter").syntax(palette_highlights)
			local highlighters = {
				hex_color = hipatterns.gen_highlighter.hex_color {
					style = "inline",
					inline_text = " ",
				},
				palette_colors = gen_palette_colors(),
				group_colors = gen_group_colors(),
			}
			hipatterns.setup {
				highlighters = vim.tbl_extend("force", highlighters, palette_patterns),
			}
		end,
	},
	-- Modern folds
	{
		"kevinhwang91/nvim-ufo",
		enable = false,
		event = "VeryLazy",
		dependencies = "kevinhwang91/promise-async",
		opts = function()
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			local handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = ("  %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth + 4
				local curWidth = 0

				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end

				table.insert(
					newVirtText,
					{ " " .. ("┄"):rep(targetWidth - curWidth - sufWidth - 2) .. "", "UfoVirtTextPill" }
				)
				table.insert(newVirtText, { suffix, "UfoVirtText" })
				table.insert(newVirtText, { "", "UfoVirtTextPill" })
				return newVirtText
			end

			return {
				fold_virt_text_handler = handler,
				provider_selector = function() return { "treesitter", "indent" } end,
			}
		end,
	},
	-- Scrollbar with git signs and diagnostics
	{
		"lewis6991/satellite.nvim",
		event = "VeryLazy",
		opts = {
			winblend = 0,
			handlers = {
				cursor = {
					enable = true,
					symbols = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" },
				},
			},
		},
	},
}
