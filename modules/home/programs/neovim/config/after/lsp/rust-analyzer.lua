return {
	settings = {
		["rust-analyzer"] = {
			semanticHighlighting = {
				punctuation = {
					enable = true,
					macro = { bang = true },
				},
			},
			diagnostics = {
				enable = true,
				experimental = { enable = true },
			},
			assist = { emitMustUse = true },
			procMacro = { enable = true },
		},
	},
}
