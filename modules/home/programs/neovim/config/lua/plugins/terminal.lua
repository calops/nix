return {
	-- Floating terminal window
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		keys = {
			{
				"<C-h>",
				function() require("toggleterm").toggle(1, 0, "", "vertical") end,
				desc = "Toggle terminal in vertical split",
				mode = { "n", "t" },
			},
			{
				"<C-f>",
				function() require("toggleterm").toggle(1, 0, "", "float") end,
				desc = "Toggle floating terminal",
				mode = { "n", "t" },
			},
			{
				"<C-S-g>",
				function() require("toggleterm").toggle(1, 0, "", "tab") end,
				desc = "Toggle terminal in new tab",
				mode = { "n", "t" },
			},
		},
		opts = {
			direction = "vertical",
			float_opts = { border = "rounded" },
			size = function() return vim.o.columns * 0.3 end,
			highlights = {
				Normal = { link = "Normal" },
				FloatBorder = { link = "TermFloatBorder" },
			},
			persist_mode = false,
			on_open = function(term)
				vim.wo[term.window].foldmethod = "manual"
				vim.wo[term.window].statuscolumn = ""
			end,
		},
	},
}
