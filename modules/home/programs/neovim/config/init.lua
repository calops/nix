-- Make shared nix-generated files available
local dataDir = vim.fn.stdpath("data")
package.path = package.path .. ";" .. dataDir .. "/lua/?.lua;" .. dataDir .. "/nix/?.lua"

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

if pcall(require, "nix") then
	vim.defer_fn(function() vim.notify("Nix environment detected", "info") end, 500)
end

require("lazy").setup {
	spec = { { import = "plugins" } },
	ui = { border = "rounded" },
}

require("neovide")
require("diagnostics")
require("core.symbols").define_signs {
	GitSignsAdd = { text = "▋", texthl = "GitSignsAdd", numhl = "" },
	GitSignsChange = { text = "▋", texthl = "GitSignsChange", numhl = "" },
	GitSignsDelete = { text = "▋", texthl = "GitSignsDelete", numhl = "" },
}
