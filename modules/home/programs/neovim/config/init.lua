-- Make shared nix-generated files available
package.path = package.path .. ";${config.xdg.dataHome}/lua/?.lua" .. ";${config.xdg.dataHome}/nix/?.lua"

if pcall(require, "nix") then
	vim.notify("Nix environment detected", "info", { title = "Neovim" })
end

vim.loader.enable()

---------- Settings
-- Search
vim.o.ignorecase = true
vim.o.inccommand = "nosplit"
vim.o.smartcase = true

-- Edit
vim.g.mapleader = ","
vim.o.colorcolumn = "120"
vim.o.concealcursor = "nc"
vim.o.textwidth = 0
vim.o.virtualedit = "block"
vim.o.undofile = true
vim.o.exrc = true

-- GUI
vim.o.background = "dark"
vim.o.cursorline = true
vim.o.guicursor = "i:ver35,a:blinkwait300-blinkoff300-blinkon300"
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumblend = 0
vim.o.scrolloff = 4
vim.o.shortmess = "c"
vim.o.termguicolors = true
vim.o.winblend = 0
vim.o.wrap = false
vim.o.hidden = true
vim.opt.fillchars = {
	eob = " ",
	fold = "⋅",
	foldopen = "󰅀",
	foldclose = "󰅂",
	foldsep = " ",
	diff = "╳",
}
vim.opt.listchars = {
	tab = "→ ",
	nbsp = "␣",
	trail = "~",
	precedes = "«",
	extends = "»",
}

-- Indentation
vim.o.autoindent = true
vim.o.expandtab = false
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.splitkeep = "screen"

-- Mouse
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.mousemoveevent = true
vim.o.mousescroll = "ver:2,hor:2"
vim.o.smoothscroll = true

-- Folds
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.o.foldlevel = 99

-- Neovide configuration
vim.g.neovide_floating_blur_amount_x = 1.5
vim.g.neovide_floating_blur_amount_y = 1.5
vim.g.neovide_scroll_animation_length = 0.13
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5
vim.g.neovide_unlink_border_highlights = true
vim.g.neovide_refresh_rate = 60
vim.g.neovide_cursor_smooth_blink = true

if vim.g.neovide == true then
	local function set_scale(scale)
		vim.g.neovide_scale_factor = scale
		-- Force redraw, otherwise the scale change won't be rendered until the next UI update
		vim.cmd.redraw { bang = true }
	end

	vim.keymap.set("n", "<C-+>", function() set_scale(vim.g.neovide_scale_factor + 0.1) end)
	vim.keymap.set("n", "<C-->", function() set_scale(vim.g.neovide_scale_factor - 0.1) end)
	vim.keymap.set("n", "<C-0>", function() set_scale(1.0) end)
end

vim.diagnostic.config {
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
		linehl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticLineError",
			[vim.diagnostic.severity.WARN] = "DiagnosticLineWarn",
			[vim.diagnostic.severity.INFO] = "DiagnosticLineInfo",
			[vim.diagnostic.severity.HINT] = "DiagnosticLineHint",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
			[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
			[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
		},
	},
}

require("core.symbols").define_signs {
	GitSignsAdd = { text = "▋", texthl = "GitSignsAdd", numhl = "" },
	GitSignsChange = { text = "▋", texthl = "GitSignsChange", numhl = "" },
	GitSignsDelete = { text = "▋", texthl = "GitSignsDelete", numhl = "" },
}

require("lazy").setup {
	spec = { { import = "plugins" } },
	ui = { border = "rounded" },
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
	dev = {
		fallback = true,
		path = "~/projects",
	},
}
