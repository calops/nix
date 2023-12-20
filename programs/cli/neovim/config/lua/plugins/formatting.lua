local map = require("core.utils").map

return {
	{
		"stevearc/conform.nvim",
		event = { "BufRead" },
		cmd = { "ConformInfo" },
		init = function()
			vim.api.nvim_create_user_command("Format", function(args)
				local range = nil
				if args.count ~= -1 then
					local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
					range = {
						start = { args.line1, 0 },
						["end"] = { args.line2, end_line:len() },
					}
				end
				require("conform").format { async = true, lsp_fallback = true, range = range }
			end, { range = true })

			map {
				["<space>f"] = { ":Format<cr>", "Format code", mode = { "n", "x" } },
			}
		end,
		opts = function()
			return {
				formatters_by_ft = {
					javascript = { "prettierd" },
					json = { "prettierd" },
					yaml = { "prettierd" },

					lua = { "stylua" },
					nix = { "alejandra" },
					python = { "isort", "black" },
					sh = { "shfmt" },
					sql = { "sqlfluff" },
				},
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 500,
				},
				formatters = {
					sqlfluff = {
						args = { "format", "--dialect=postgres", "-" },
					},
				},
			}
		end,
	},
}
