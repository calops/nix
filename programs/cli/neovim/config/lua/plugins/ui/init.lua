local core_utils = require("core.utils")
local utils = require("plugins.ui.utils")
local palette = require("nix.palette")
local map = core_utils.map

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", numhl = "" })

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
		-- Wait for the plugin to become more stable
		version = "*",
		enabled = true,
		config = function()
			local bar = require("dropbar.bar")
			local palette = utils.palette()
			local sources = require("dropbar.sources")
			local function wrap_path(buf, win, cursor)
				local symbols_len = 0
				local symbols = {
					content = {},
					insert = function(self, elt)
						symbols_len = symbols_len + 1
						if type(elt.hl) == "table" then
							elt.name_hl = utils.get_hl_group(elt.hl)
						end
						table.insert(self.content, symbols_len, elt)
					end,
				}
				local path_symbols = sources.path.get_symbols(buf, win, cursor)
				local left, mid = {}, {}
				for i, item in ipairs(path_symbols) do
					if i < #path_symbols then
						if i ~= 1 then
							item.lite = true
						end
						item.hl = { fg = palette.text, bg = palette.surface1 }
						item.icon_hl = utils.get_hl_group {
							fg = utils.get_hl(item.icon_hl).fg,
							bg = palette.surface1,
						}
						table.insert(left, item)
					else
						if vim.api.nvim_get_current_buf() == buf then
							item.hl = {
								fg = palette.peach,
								bg = palette.overlay0,
								style = { "bold" },
							}
						else
							item.hl = {
								fg = palette.text,
								bg = palette.surface1,
							}
						end
						table.insert(left, {
							name = item.icon,
							hl = utils.get_hl(item.icon_hl),
						})
						item.icon = nil
						mid = item
					end
				end
				local pill = utils.build_pill(left, mid, {}, "name")
				for _, item in ipairs(pill) do
					if not item.win then
						item = bar.dropbar_symbol_t:new(item)
					end
					symbols:insert(item)
				end

				return symbols.content
			end
			require("dropbar").setup {
				-- bar = {
				-- 	sources = function(_, _)
				-- 		return {
				-- 			-- sources.path,
				-- 			{ get_symbols = wrap_path },
				-- 			{
				-- 				get_symbols = function(_, _, _)
				-- 					return { bar.dropbar_symbol_t:new { name = "%=" } }
				-- 				end,
				-- 			},
				-- 			{
				-- 				get_symbols = function(buf, win, cursor)
				-- 					if vim.bo[buf].ft == "markdown" then
				-- 						return sources.markdown.get_symbols(buf, win, cursor)
				-- 					end
				-- 					for _, source in ipairs {
				-- 						sources.lsp,
				-- 						sources.treesitter,
				-- 					} do
				-- 						local symbols = source.get_symbols(buf, win, cursor)
				-- 						if not vim.tbl_isempty(symbols) then
				-- 							table.remove(symbols, 1)
				-- 							return core_utils.reverse_table(symbols)
				-- 						end
				-- 					end
				-- 					return {}
				-- 				end,
				-- 			},
				-- 		}
				-- 	end,
				-- },
				-- icons = { ui = { bar = { separator = "" } } },
				menu = {
					win_configs = {
						border = "rounded",
					},
				},
			}
		end,
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
		opts = {
			show_current_context = true,
			show_current_context_start = false,
			use_treesitter = true,
			use_treesitter_scope = false,
			max_indent_increase = 1,
			show_trailing_blankline_indent = false,
			blankline_char_priority = 10,
			integrations = {
				neotree = {
					enabled = true,
					show_root = false,
					transparent_panel = false,
				},
			},
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
			local palette = utils.palette()
			local hipatterns = require("mini.hipatterns")
			local palette_patterns = {}
			local palette_highlights = {}

			for name, color in pairs(palette) do
				palette_patterns[name] = {
					pattern = "%f[%w]palette[.]()" .. name .. "()%f[%W]",
					group = "HiPatternsPalette_" .. name,
				}
				palette_highlights["HiPatternsPalette_" .. name] = {
					bg = color,
					fg = utils.compute_opposite_color(color:lower():sub(2)),
				}
			end

			local function gen_palette_colors()
				return {
					pattern = function(bufnr)
						if vim.api.nvim_buf_get_name(bufnr):match("theme.lua$") then
							return "utils[.]%w*[(]palette[.].*, %d[.]%d+[)]"
						end
						return nil
					end,
					group = function(_, _, data)
						local func, base_color, ratio =
							data.full_match:match("utils[.](%w*)[(]palette[.](.*), (%d[.]%d+)[)]")
						local group_name = "HiPatternsPalette_"
							.. base_color
							.. "_"
							.. func
							.. "_"
							.. ratio:gsub("%.", "_")
						base_color = palette[base_color]
						local bg_color = utils[func](base_color, tonumber(ratio))
						local fg_color = utils.compute_opposite_color(bg_color:lower():sub(2))
						if vim.fn.hlexists(group_name) == 0 then
							require("catppuccin.lib.highlighter").syntax {
								[group_name] = {
									fg = fg_color,
									bg = bg_color,
								},
							}
						end

						return group_name
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
							local palette = require("catppuccin.palettes").get_palette()
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
				hex_color = hipatterns.gen_highlighter.hex_color(),
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
		config = function()
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

			require("ufo").setup {
				fold_virt_text_handler = handler,
				provider_selector = function() return { "treesitter", "indent" } end,
			}
		end,
	},
	-- Scrollbar with git signs and diagnostics
	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		opts = {
			handle = {
				color = palette.surface1,
			},
			handlers = {
				gitsigns = true,
			},
		},
	},
}
