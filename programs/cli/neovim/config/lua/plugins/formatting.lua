local map = require("core.utils").map

return {
	{
		"elentok/format-on-save.nvim",
		cmd = { "Format" },
		event = { "BufRead" },
		init = function()
			map {
				["<space>f"] = { ":Format<cr>", "Format code" },
			}
		end,
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
