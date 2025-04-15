local function hl_override(palette)
	local colors = require("core.colors")

	return {
		Error = { fg = palette.red },
		Warning = { fg = palette.yellow },
		Info = { fg = palette.sky },
		Hint = { fg = palette.teal },

		ErrorSign = { fg = palette.red, bg = colors.darken(palette.red, 0.095) },
		WarnSign = { fg = palette.yellow, bg = colors.darken(palette.yellow, 0.095) },
		InfoSign = { fg = palette.sky, bg = colors.darken(palette.sky, 0.095) },
		HintSign = { fg = palette.teal, bg = colors.darken(palette.teal, 0.095) },

		CursorLine = { bg = palette.surface0 },
		CursorLineSign = { link = "CursorLine" },
		LineNr = { fg = palette.surface2 },
		CursorLineNr = { fg = palette.lavender, bg = palette.surface0 },
		ColorColumn = { bg = palette.mantle },

		NormalFloat = { bg = palette.base },
		FloatBorder = { fg = palette.mauve },
		TermFloatBorder = { fg = palette.red },

		SnacksPickerMatch = { sp = palette.peach, fg = palette.peach, style = { "underline" } },
		SnacksIndentScope = { fg = palette.mauve },

		BlinkCmpMenu = { link = "NormalFloat" },
		BlinkCmpMenuBorder = { fg = palette.mauve },
		BlinkCmpDocBorder = { fg = palette.green },
		BlinkCmpSignatureHelpBorder = { fg = palette.peach },
		BlinkCmpGhostText = { fg = palette.surface2 },

		GlancePreviewMatch = { bg = colors.darken(palette.peach, 0.2) },
		GlanceListMatch = { fg = palette.peach },

		Search = {
			fg = palette.yellow,
			bg = colors.darken(palette.yellow, 0.095),
			sp = palette.yellow,
			style = { "bold", "underline" },
		},
		CurSearch = {
			fg = palette.peach,
			bg = colors.darken(palette.peach, 0.095),
			sp = palette.peach,
			style = { "bold", "underline" },
		},

		InclineNormal = { fg = palette.base, bg = palette.sapphire, style = { "bold" } },
		InclineNormalNC = { fg = palette.sapphire, bg = colors.darken(palette.sapphire, 0.33) },

		EdgyNormal = { bg = palette.mantle },
		TroubleNormal = { bg = palette.mantle },

		TreesitterContext = { bg = palette.base, style = { "italic" }, blend = 0 },
		TreesitterContextSeparator = { fg = palette.surface1 },
		TreesitterContextBottom = { bg = palette.base, sp = palette.surface1, style = { "underdashed" } },
		TreesitterContextLineNumber = { link = "LineNr" },

		DiagnosticLineError = { bg = colors.darken(palette.red, 0.095, palette.base) },
		DiagnosticLineWarn = { bg = colors.darken(palette.yellow, 0.095, palette.base) },
		DiagnosticLineInfo = { bg = colors.darken(palette.sky, 0.095, palette.base) },
		DiagnosticLineHint = { bg = colors.darken(palette.teal, 0.095, palette.base) },

		DiagnosticSignError = { fg = palette.red, bg = colors.darken(palette.red, 0.095) },
		DiagnosticSignWarn = { fg = palette.yellow, bg = colors.darken(palette.yellow, 0.095) },
		DiagnosticSignInfo = { fg = palette.sky, bg = colors.darken(palette.sky, 0.095) },
		DiagnosticSignHint = { fg = palette.teal, bg = colors.darken(palette.teal, 0.095) },

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

		Comment = { fg = colors.darken(palette.lavender, 0.6) },

		IlluminatedWordText = { bg = palette.surface1, style = { "bold", "underdotted" } },
		IlluminatedWordWrite = { bg = palette.surface1, style = { "bold", "underdotted" } },
		IlluminatedWordRead = { bg = palette.surface1, style = { "bold", "underdotted" } },

		Folded = { bg = palette.base, style = { "italic" }, fg = palette.overlay0 },

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
		CustomTablineLspActive = { fg = palette.green, bg = colors.darken(palette.green, 0.33), style = { "bold" } },
		CustomTablineLspInactive = { fg = palette.text, bg = colors.darken(palette.green, 0.33) },
		CustomTablineCwd = { fg = palette.yellow, bg = colors.darken(palette.yellow, 0.33) },
		CustomTablineCwdIcon = { fg = palette.base, bg = palette.yellow },
		CustomTablineGitBranch = { fg = palette.peach, bg = colors.darken(palette.peach, 0.33) },
		CustomTablineGitIcon = { fg = palette.base, bg = palette.peach },

		CopilotSuggestion = { fg = colors.darken(palette.peach, 0.8), style = { "italic" } },

		AvanteSidebarNormal = { bg = palette.mantle, fg = palette.text },
		AvanteSidebarWinSeparator = { bg = palette.mantle, fg = palette.mantle },
		AvanteSidebarWinHorizontalSeparator = { bg = palette.mantle, fg = palette.surface0 },

		FlashLabel = { bg = palette.peach, fg = palette.base, style = { "bold" } },
		FlashMatch = { bg = palette.lavender, fg = palette.base },
		FlashBackdrop = { bg = nil, fg = palette.overlay0, style = { "nocombine" } },

		LazyCommitTypeFeat = { sp = palette.blue, style = { "underline" } },

		-- Syntax
		["@variable.parameter"] = { fg = palette.text, style = { "nocombine" } },
		["@module"] = { fg = palette.pink, style = { "nocombine" } },
		["@number"] = { fg = palette.peach },
		["@boolean"] = { fg = palette.green, style = { "bold" } },
		["@type.qualifier"] = { fg = palette.mauve, style = { "bold" } },
		["@function.macro"] = { fg = palette.blue },
		["@constant.builtin"] = { fg = palette.green },
		["@property"] = { fg = colors.brighten(palette.yellow, 0.7) },
		["@variable.member"] = { fg = colors.brighten(palette.yellow, 0.7) },

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
end

-- Theme
return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 10000,
	opts = {
		flavour = "mocha",
		term_colors = true,
		integrations = {
			blink_cmp = true,
			neotest = true,
			noice = true,
			diffview = true,
			gitsigns = true,
			mini = true,
			snacks = true,
			lsp_trouble = true,
			which_key = true,
			native_lsp = {
				enabled = true,
				inlay_hints = { background = false },
				underlines = {
					errors = { "undercurl" },
					hints = { "undercurl" },
					warnings = { "undercurl" },
					information = { "undercurl" },
					ok = { "underline" },
				},
			},
		},
		compile = {
			enabled = true,
		},
		highlight_overrides = {
			all = hl_override,
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
