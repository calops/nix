-- Install plugin manager
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
-- 	vim.fn.system {
-- 		"git",
-- 		"clone",
-- 		"--filter=blob:none",
-- 		"--single-branch",
-- 		"git@github.com:folke/lazy.nvim.git",
-- 		lazypath,
-- 	}
-- end
-- vim.opt.runtimepath:prepend(lazypath)

---------- Settings
-- Search
vim.o.ignorecase = true
vim.o.inccommand = "nosplit"
vim.o.smartcase = true

-- Edit
vim.g.mapleader = ","
vim.o.colorcolumn = "120"
vim.o.concealcursor = "nc"
vim.o.textwidth = 120
vim.o.virtualedit = "block"
require("editorconfig").properties.insert_final_newline = nil

-- GUI
vim.o.background = "dark"
vim.o.cursorline = true
vim.o.guicursor = "a:blinkon100"
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.pumblend = 0
vim.o.scrolloff = 4
vim.o.shortmess = "c"
vim.o.termguicolors = true
vim.o.winblend = 0
vim.o.wrap = false
vim.opt.fillchars = {
	eob = " ",
	fold = " ",
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

-- Mouse
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.mousemoveevent = true
vim.o.mousescroll = "ver:6,hor:6"
vim.o.smoothscroll = true

-- Neovide configuration
vim.g.neovide_floating_blur_amount_x = 1.5
vim.g.neovide_floating_blur_amount_y = 1.5
vim.g.neovide_scroll_animation_length = 0.13
vim.o.guifont = "Iosevka Comfy:h10"

-- Clipboard
-- vim.g.clipboard = {
-- 	name = "OSC 52",
-- 	copy = {
-- 		["+"] = require("vim.clipboard.osc52").copy,
-- 		["*"] = require("vim.clipboard.osc52").copy,
-- 	},
-- }

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint", numhl = "" })

vim.fn.sign_define("GitSignsAdd", { text = "┃", texthl = "GitSignsAdd", numhl = "" })
vim.fn.sign_define("GitSignsChange", { text = "┃", texthl = "GitSignsChange", numhl = "" })
vim.fn.sign_define("GitSignsDelete", { text = "┃", texthl = "GitSignsDelete", numhl = "" })

require("lazy").setup("plugins", {
	ui = { border = "rounded" },
	dev = {
		fallback = true,
		path = "~/github",
	},
})

local group = vim.api.nvim_create_augroup("HelpHandler", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "*.txt",
	group = group,
	callback = function()
		if vim.bo.buftype == "help" and vim.wo.winfixwidth == false then
			vim.cmd([[wincmd L | vert resize 80 | set winfixwidth | wincmd =]])
		end
	end,
})

-- Full line error highlights
local utils = require("plugins.ui.utils")
local lines_ns = vim.api.nvim_create_namespace("diag_lines")

local function clear_highlights(buf) vim.api.nvim_buf_clear_namespace(buf, lines_ns, 0, -1) end

local function update_highlights(buf, diagnostics)
	clear_highlights(buf)

	for _, diagnostic in ipairs(diagnostics) do
		vim.api.nvim_buf_set_extmark(buf, lines_ns, diagnostic.lnum, 0, {
			hl_mode = "combine",
			hl_eol = true,
			hl_group = utils.diags_lines()[diagnostic.severity],
			end_row = diagnostic.lnum + 1,
			priority = 14 - diagnostic.severity,
		})
	end
end

vim.diagnostic.handlers.diagnostic_lines = {
	show = function(_, bufnr, diagnostics, _) update_highlights(bufnr, diagnostics) end,
	hide = function(_, bufnr) clear_highlights(bufnr) end,
}
