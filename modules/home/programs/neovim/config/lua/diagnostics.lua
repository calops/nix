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

local virtual_text_config = { source = true }
local virtual_lines_config = { source = true }

vim.diagnostic.config {
	severity_sort = true,
	virtual_text = virtual_text_config,
	virtual_lines = false,
}

require("core.utils").map {
	{
		"<leader>m",
		function()
			local is_enabled = vim.diagnostic.config().virtual_lines
			vim.diagnostic.config {
				virtual_lines = (not is_enabled) and virtual_lines_config or false,
				virtual_text = is_enabled and virtual_text_config or false,
			}
		end,
		desc = "Toggle full inline diagnostics",
	},
}
