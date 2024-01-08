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
				local colors = require("core.colors")
				local palette = colors.palette()

				return {
					Error = { fg = palette.red },
					Warning = { fg = palette.yellow },
					Info = { fg = palette.sky },
					Hint = { fg = palette.teal },

					ErrorSign = { fg = palette.red, bg = colors.darken(palette.red, 0.095, palette.base) },
					WarnSign = { fg = palette.yellow, bg = colors.darken(palette.yellow, 0.095, palette.base) },
					InfoSign = { fg = palette.sky, bg = colors.darken(palette.sky, 0.095, palette.base) },
					HintSign = { fg = palette.teal, bg = colors.darken(palette.teal, 0.095, palette.base) },

					CursorLine = { bg = palette.surface0 },
					CursorLineSign = { link = "CursorLine" },
					LineNr = { fg = palette.surface2 },
					CursorLineNr = { fg = palette.lavender, bg = palette.surface0 },

					NormalFloat = { bg = palette.base },
					FloatBorder = { fg = palette.mauve },
					TermFloatBorder = { fg = palette.red },

					TelescopeBorder = { fg = palette.yellow },
					TelescopePromptBorder = { fg = palette.peach },
					TelescopePreviewBorder = { fg = palette.teal },
					TelescopeResultsBorder = { fg = palette.green },

					InclineNormal = { fg = palette.base, bg = palette.sapphire, style = { "bold" } },
					InclineNormalNC = { fg = palette.sapphire, bg = colors.darken(palette.sapphire, 0.33) },

					TreesitterContext = { bg = palette.base, style = { "italic" }, blend = 0 },
					TreesitterContextSeparator = { fg = palette.surface1 },
					TreesitterContextBottom = { bg = palette.base, sp = palette.surface1, style = { "underdashed" } },

					DiagnosticUnderlineError = { sp = palette.red, style = { "undercurl" } },
					DiagnosticUnderlineWarn = { sp = palette.yellow, style = { "undercurl" } },
					DiagnosticUnderlineInfo = { sp = palette.sky, style = { "undercurl" } },
					DiagnosticUnderlineHint = { sp = palette.teal, style = { "undercurl" } },
					DiagnosticUnnecessary = { sp = palette.mauve, style = { "undercurl" } },

					DiagnosticLineError = { bg = colors.darken(palette.red, 0.095, palette.base) },
					DiagnosticLineWarn = { bg = colors.darken(palette.yellow, 0.095, palette.base) },
					DiagnosticLineInfo = { bg = colors.darken(palette.sky, 0.095, palette.base) },
					DiagnosticLineHint = { bg = colors.darken(palette.teal, 0.095, palette.base) },

					SatelliteDiagnosticError = { fg = colors.darken(palette.red, 0.5, palette.base) },
					SatelliteDiagnosticWarn = { fg = colors.darken(palette.yellow, 0.5, palette.base) },
					SatelliteDiagnosticInfo = { fg = colors.darken(palette.sky, 0.5, palette.base) },
					SatelliteDiagnosticHint = { fg = colors.darken(palette.teal, 0.5, palette.base) },

					IblScope = { fg = palette.mauve },

					ModeNormal = { fg = palette.blue, bg = colors.darken(palette.blue, 0.33), style = { "bold" } },
					ModeInsert = { fg = palette.green, bg = colors.darken(palette.green, 0.33), style = { "bold" } },
					ModeVisual = { fg = palette.mauve, bg = colors.darken(palette.mauve, 0.33), style = { "bold" } },
					ModeOperator = { fg = palette.peach, bg = colors.darken(palette.peach, 0.33), style = { "bold" } },
					ModeReplace = { fg = palette.yellow, bg = colors.darken(palette.yellow, 0.33), style = { "bold" } },
					ModeCommand = { fg = palette.sky, bg = colors.darken(palette.sky, 0.33), style = { "bold" } },
					ModePrompt = { fg = palette.teal, bg = colors.darken(palette.teal, 0.33), style = { "bold" } },
					ModeTerminal = { fg = palette.red, bg = colors.darken(palette.red, 0.33), style = { "bold" } },

					MacroRecording = { fg = palette.base, bg = palette.pink, style = { "bold" } },

					ModesInsert = { link = "ModeInsert" },
					ModesVisual = { link = "ModeVisual" },

					LspInlayHint = { fg = palette.surface1 },
					Comment = { fg = colors.darken(palette.lavender, 0.6) },

					IlluminatedWordText = { bg = palette.surface1, style = { "bold", "underdotted" } },
					IlluminatedWordWrite = { bg = palette.surface1, style = { "bold", "underdotted" } },
					IlluminatedWordRead = { bg = palette.surface1, style = { "bold", "underdotted" } },

					UfoVirtText = { fg = palette.base, bg = palette.teal, style = { "bold" } },
					UfoVirtTextPill = { fg = palette.teal },
					UfoFoldedBg = { bg = colors.darken(palette.teal, 0.33) },
					Folded = { bg = palette.base },

					GitSignsAdd = { fg = palette.green },
					GitSignsChange = { fg = palette.peach },
					GitSignsDelete = { fg = palette.red },
					GitSignsAddInline = { bg = colors.darken(palette.green, 0.50) },
					GitSignsChangeInline = { bg = colors.darken(palette.peach, 0.50) },
					GitSignsDeleteInline = { bg = colors.darken(palette.red, 0.50) },

					DiffDeleteVirtLn = { fg = colors.darken(palette.red, 0.3) },
					DiffviewDiffDeleteDim = { fg = palette.surface0 },

					CustomTabline = { fg = palette.mauve, bg = colors.darken(palette.mauve, 0.33) },
					CustomTablineSel = { fg = palette.base, bg = palette.mauve },
					CustomTablineLogo = { fg = palette.mauve },
					CustomTablinePillIcon = { bg = colors.darken(palette.mauve, 0.33) },
					CustomTablinePillIconSel = { bg = colors.darken(palette.mauve, 0.33) },
					CustomTablineModifiedIcon = { fg = palette.peach, bg = colors.darken(palette.peach, 0.33) },
					CustomTablineNumber = { style = { "bold" } },
					CustomTablineLsp = { fg = palette.base, bg = palette.green },
					CustomTablineLspActive = {
						fg = palette.green,
						bg = colors.darken(palette.green, 0.33),
						style = { "bold" },
					},
					CustomTablineLspInactive = { fg = palette.text, bg = colors.darken(palette.green, 0.33) },
					CustomTablineCwd = { fg = palette.yellow, bg = colors.darken(palette.yellow, 0.33) },
					CustomTablineCwdIcon = { fg = palette.base, bg = palette.yellow },
					CustomTablineGitBranch = { fg = palette.peach, bg = colors.darken(palette.peach, 0.33) },
					CustomTablineGitIcon = { fg = palette.base, bg = palette.peach },

					VirtColumn = { fg = palette.surface0 },

					CopilotSuggestion = { fg = colors.darken(palette.peach, 0.8), style = { "italic" } },

					FlashLabel = { bg = palette.peach, fg = palette.base, style = { "bold" } },
					FlashMatch = { bg = palette.lavender, fg = palette.base },
					FlashBackdrop = { bg = nil, fg = palette.overlay0, style = { "nocombine" } },

					SatelliteCursor = { fg = palette.mauve },

					NoiceMini = { fg = palette.blue, bg = colors.darken(palette.blue, 0.33), blend = 0 },

					-- Syntax
					["@parameter"] = { fg = palette.text, style = { "nocombine" } },
					["@namespace"] = { fg = palette.pink, style = { "nocombine" } },
					["@number"] = { fg = palette.green },
					["@boolean"] = { fg = palette.green, style = { "bold" } },
					["@type.qualifier"] = { fg = palette.mauve, style = { "bold" } },
					["@function.macro"] = { fg = palette.blue },
					["@constant.builtin"] = { fg = palette.green },
					["@property"] = { fg = colors.brighten(palette.yellow, 0.7) },
					["@field"] = { fg = colors.brighten(palette.yellow, 0.7) },

					["@lsp.type.struct"] = { fg = palette.yellow },
					["@lsp.type.property"] = { fg = colors.brighten(palette.yellow, 0.7) },
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

					["@lsp.typemod.property.withAttribute.nix"] = { style = { "italic" } },
				}
			end,
		}
		vim.cmd.colorscheme("catppuccin")
	end,
}
