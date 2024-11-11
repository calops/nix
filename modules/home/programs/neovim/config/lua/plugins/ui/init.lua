local utils = require("core.utils")
local colors = require("core.colors")

return {
	-- TUI
	{
		"rebelot/heirline.nvim",
		lazy = false,
		keys = function()
			local function new_tab()
				local view = vim.fn.winsaveview()
				vim.cmd.tabedit("%")
				if view then
					vim.fn.winrestview(view)
				else
					vim.notify("Failed to save view for new tab", vim.log.levels.WARN)
				end
			end

			return {
				{ "<C-t>", new_tab, desc = "Open current buffer in new tab" },
				{ "<C-S-t>", ":tabclose<CR>", desc = "Close current tab" },
				{ "<C-Tab>", ":tabnext<CR>", desc = "View next tab" },
				{ "<C-S-Tab>", ":tabprevious<CR>", desc = "View previous tab" },
			}
		end,
		config = function()
			vim.o.signcolumn = "no"
			vim.o.foldcolumn = "0"
			vim.go.laststatus = 3
			vim.go.showtabline = 0

			require("gitsigns") -- Dependency
			require("heirline").setup {
				statuscolumn = require("plugins.ui.statuscolumn"),
				statusline = require("plugins.ui.statusline"),
			}
		end,
	},
	require("plugins.ui.windowline"),
	-- Colorful modes
	{
		"mvllow/modes.nvim",
		event = "VeryLazy",
		config = true,
	},
	-- CMD line replacement and other UI niceties
	{
		"folke/noice.nvim",
		lazy = false,
		keys = {
			{ "<leader><leader>", ":noh<CR>", desc = "Hide search highlights" },
		},
		opts = {
			presets = {
				bottom_search = false,
				lsp_doc_border = true,
				command_palette = true,
			},
			views = { messages = { backend = "popup" } },
			popupmenu = { enabled = true, backend = "nui" },
			routes = {
				{
					filter = { event = "msg_show", find = '"*"*lines --*%--' },
					view = "notify",
					opts = { skip = true },
				},
			},
			messages = {
				view = "mini",
				view_error = "notify",
				view_warn = "notify",
				view_search = "virtualtext",
				view_history = "messages",
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
				signature = { enabled = false }, -- Handled by blink
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
		commit = "e7a4442e055ec953311e77791546238d1eaae507", -- FIXME: unpin once solved upstream
		enabled = true,
		event = "BufRead",
		main = "ibl",
		opts = {
			indent = {
				char = "▎",
				tab_char = "▎",
			},
			scope = {
				show_start = false,
				show_end = false,
				include = {
					node_type = {
						lua = { "table_constructor" },
						nix = { "attrset_expression", "list_expression" },
					},
				},
			},
		},
	},
	-- Notification handler, and various utilities
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = {
				timeout = 5000,
				sort = { "added" },
			},
			styles = { notification = { wo = { wrap = true } } },
		},
		keys = {
			{ "<leader>k", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
			{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
			{ "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
			{ "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
		},
		init = function()
			require("core.utils").user_aucmd("VeryLazy", function()
				---@diagnostic disable-next-line: duplicate-set-field
				_G.dd = function(...) Snacks.debug.inspect(...) end
				---@diagnostic disable-next-line: duplicate-set-field
				_G.bt = function() Snacks.debug.backtrace() end
				vim.print = _G.dd

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.line_number():map("<leader>ul")
				Snacks.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>uc")
				Snacks.toggle.treesitter():map("<leader>uT")
				Snacks.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				Snacks.toggle.inlay_hints():map("<leader>uh")

				utils.map { { "<leader>u", name = "Toggles" } }
			end)
		end,
	},
	-- Keymaps cheat sheet and tooltips
	{
		"folke/which-key.nvim",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 150
		end,
		opts = {
			preset = "helix",
		},
	},
	{
		"echasnovski/mini.hipatterns",
		event = "VeryLazy",
		config = function()
			local hipatterns = require("mini.hipatterns")
			local palette_patterns = {}
			local palette_highlights = {}

			for name, color in pairs(colors.palette()) do
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
							return "colors[.]%w*[(]palette[.].*, %d[.]%d+[)]"
						end
						return nil
					end,
					group = "",
					extmark_opts = function(_, _, data)
						local func, base_color, ratio =
							data.full_match:match("colors[.](%w*)[(]palette[.](.*), (%d[.]%d+)[)]")
						local group_name = "HiPatternsPalette_"
							.. base_color
							.. "_"
							.. func
							.. "_"
							.. ratio:gsub("%.", "_")
						base_color = colors.palette()[base_color]
						if vim.fn.hlexists(group_name) == 0 then
							require("catppuccin.lib.highlighter").syntax {
								[group_name] = {
									fg = colors[func](base_color, tonumber(ratio)),
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
							return "()[^	 ]*() += {.*palette.*}"
						end
						return nil
					end,
					group = function(_, _, data)
						local group, body = data.full_match:match("([^{ ]*) += ({.*})$")
						group = group:gsub('[]"[]+', "")
						local group_name = "HiPatternsGroup_" .. group
						local group_def = loadstring([[
							local colors = require("core.colors")
							local palette = colors.palette()
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
	-- Create sidebars and docks
	{
		"folke/edgy.nvim",
		event = "VeryLazy",
		opts = {
			animate = { enabled = false },
			options = { right = { size = 80 } },
			bottom = {
				"Trouble",
				{ ft = "qf", title = "QuickFix" },
			},
			right = {
				"copilot-chat",
				{
					ft = "help",
					filter = function(buf) return vim.bo[buf].buftype == "help" end,
					wo = { statuscolumn = "" },
				},
			},
		},
	},
	{
		"calops/virtsign.nvim",
		enabled = false,
		event = "VeryLazy",
		dev = true,
	},
}
