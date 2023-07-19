return {
	{
		"elentok/format-on-save.nvim",
		opts = function()
			local formatters = require("format-on-save.formatters")

			return {
				partial_update = true,
				formatter_by_ft = {
					json = formatters.lsp,
					lua = formatters.stylua,
					nix = formatters.shell { cmd = { "alejandra", "--quiet" } },
					rust = formatters.lsp,
					sh = formatters.shfmt,
					sql = formatters.shell { cmd = { "sqlfluff" } },
					yaml = formatters.lsp,
				},
			}
		end,
	},
}
