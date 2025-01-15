return {
	{
		"folke/snacks.nvim",
		opts = {
			statuscolumn = {
				left = { "mark", "sign" },
				right = { "fold", "git" },
				folds = {
					open = false,
					git_hl = true,
				},
				git = { patterns = { "GitSign", "MiniDiffSign" } },
				refresh = 50,
			},
		},
	},
}
