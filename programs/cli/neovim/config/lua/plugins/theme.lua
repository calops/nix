-- Theme
return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup {
			flavour = "mocha",
			term_colors = true,
			integrations = {
				telescope = true,
				neotree = {
					enabled = true,
					show_root = true,
					transparent_panel = false,
				},
				indent_blankline = {
					enabled = false,
					colored_indent_levels = false,
				},
				cmp = true,
				gitsigns = true,
				notify = true,
				mini = true,
				native_lsp = {
					inlay_hints = {
						background = false,
					},
				},
			},
			compile = {
				enabled = true,
			},
			custom_highlights = function()
				local palette = require("plugins.ui.utils").palette()
				local utils = require("plugins.ui.utils")

				return {
					NormalFloat = { bg = palette.base },
					FloatBorder = { fg = palette.mauve },
					TermFloatBorder = { fg = palette.red },

					TelescopeBorder = { fg = palette.yellow },
					TelescopePromptBorder = { fg = palette.peach },
					TelescopePreviewBorder = { fg = palette.teal },
					TelescopeResultsBorder = { fg = palette.green },

					InclineNormalNC = { bg = palette.surface1, fg = palette.base, blend = 0 },
					InclineNormal = { bg = palette.overlay1, fg = palette.base, blend = 0 },

					TreesitterContext = { bg = palette.base, style = { "italic" }, blend = 0 },
					TreesitterContextSeparator = { fg = palette.surface1 },
					TreesitterContextBottom = { bg = palette.base, sp = palette.surface1, style = { "underdashed" } },

					DiagnosticUnderlineError = { sp = palette.red, style = { "undercurl" } },
					DiagnosticUnderlineWarn = { sp = palette.yellow, style = { "undercurl" } },
					DiagnosticUnderlineInfo = { sp = palette.sky, style = { "undercurl" } },
					DiagnosticUnderlineHint = { sp = palette.teal, style = { "undercurl" } },

					DiagnosticLineError = { bg = utils.darken(palette.red, 0.095, palette.base) },
					DiagnosticLineWarn = { bg = utils.darken(palette.yellow, 0.095, palette.base) },
					DiagnosticLineInfo = { bg = utils.darken(palette.sky, 0.095, palette.base) },
					DiagnosticLineHint = { bg = utils.darken(palette.teal, 0.095, palette.base) },

					DiagnosticUnnecessary = { sp = palette.mauve, style = { "undercurl" } },

					IblScope = { fg = palette.mauve },

					ModesInsert = { bg = palette.green },
					ModesVisual = { bg = palette.mauve },

					LspInlayHint = { fg = palette.surface1 },
					Comment = { fg = utils.darken(palette.lavender, 0.6) },

					IlluminatedWordText = { bg = palette.surface1, style = { "bold", "underdotted" } },
					IlluminatedWordWrite = { bg = palette.surface1, style = { "bold", "underdotted" } },
					IlluminatedWordRead = { bg = palette.surface1, style = { "bold", "underdotted" } },

					UfoVirtText = { fg = palette.base, bg = palette.teal, style = { "bold" } },
					UfoVirtTextPill = { fg = palette.teal },
					UfoFoldedBg = { bg = utils.darken(palette.teal, 0.3) },
					Folded = { bg = palette.base },

					CursorLineSign = { link = "CursorLine" },

					GitSignsAdd = { fg = palette.green, bg = "none" },
					GitSignsChange = { fg = palette.peach },
					GitSignsDelete = { fg = palette.red },
					DiffDeleteVirtLn = { fg = utils.darken(palette.red, 0.3) },
					DiffviewDiffDeleteDim = { fg = palette.surface0 },

					CustomTabline = { fg = palette.base, bg = palette.surface1 },
					CustomTablineSel = { fg = palette.base, bg = palette.overlay1 },
					CustomTablineLogo = { fg = palette.base, bg = palette.mauve },
					CustomTablinePillIcon = { bg = palette.surface1 },
					CustomTablinePillIconSel = { bg = palette.surface2 },
					CustomTablineModifiedIcon = { fg = palette.peach },
					CustomTablineNumber = { style = { "bold" } },

					VirtColumn = { fg = palette.surface0 },

					CuicuiCharColumn1 = { fg = utils.darken(palette.surface0, 0.8) },
					CuicuiCharColumn2 = { fg = palette.surface0 },

					CopilotSuggestion = { fg = utils.darken(palette.peach, 0.8), style = { "italic" } },

					MultiCursor = { bg = palette.peach, fg = palette.base },
					VM_Mono = { bg = palette.peach, fg = palette.base },

					FlashLabel = { bg = palette.peach, fg = palette.base, style = { "bold" } },
					FlashMatch = { bg = palette.lavender, fg = palette.base },
					FlashBackdrop = { bg = nil, fg = palette.overlay0, style = { "nocombine" } },

					SatelliteCursor = { fg = palette.mauve },

					-- Syntax
					["@parameter"] = { fg = palette.text, style = { "nocombine" } },
					["@namespace"] = { fg = palette.pink, style = { "nocombine" } },
					["@number"] = { fg = palette.green },
					["@boolean"] = { fg = palette.green, style = { "bold" } },
					["@type.qualifier"] = { fg = palette.mauve, style = { "bold" } },
					["@function.macro"] = { fg = palette.blue },
					["@constant.builtin"] = { fg = palette.green },
					["@property"] = { fg = utils.brighten(palette.yellow, 0.7) },
					["@field"] = { fg = utils.brighten(palette.yellow, 0.7) },

					["@lsp.type.struct"] = { fg = palette.yellow },
					["@lsp.type.property"] = { fg = utils.brighten(palette.yellow, 0.7) },
					["@lsp.type.interface"] = { fg = palette.peach },
					["@lsp.type.builtinType"] = { fg = palette.yellow, style = { "bold" } },
					["@lsp.type.enum"] = { fg = palette.teal },
					["@lsp.type.enumMember"] = { fg = palette.green },
					["@lsp.type.variable"] = { fg = palette.text },
					["@lsp.type.parameter"] = { fg = palette.text },
					["@lsp.type.namespace"] = { fg = palette.pink },
					["@lsp.type.number"] = { fg = palette.green },
					["@lsp.type.boolean"] = { fg = palette.green, style = { "bold" } },
					["@lsp.type.keyword"] = { fg = palette.mauve },
					["@lsp.type.decorator"] = { fg = palette.blue },
					["@lsp.type.unresolvedReference"] = { sp = palette.surface2, style = { "undercurl" } },
					["@lsp.type.derive.rust"] = { link = "@lsp.type.interface" },

					["@lsp.mod.reference"] = { style = { "italic" } },
					["@lsp.mod.mutable"] = { style = { "bold" } },
					["@lsp.mod.trait"] = { fg = palette.sapphire },
					["@lsp.typemod.variable.static"] = { style = { "underdashed" } },
					["@lsp.typemod.method.defaultLibrary"] = {},
					["@lsp.typemod.variable.callable"] = { fg = palette.teal },
				}
			end,
		}
		vim.cmd.colorscheme("catppuccin")
	end,
}
