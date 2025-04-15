return {
	{
		"stevearc/conform.nvim",
		event = { "BufRead" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<space>f",
				function()
					require("conform").format {
						async = true,
						lsp_format = "fallback",
					}
				end,
				desc = "Format code",
				mode = { "n", "x" },
			},
		},
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
				require("conform").format { async = true, lsp_format = "fallback", range = range }
			end, { range = true })

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})

			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
		opts = {
			formatters_by_ft = {
				json = { "prettierd" },
				yaml = { "prettierd" },
				html = { "prettierd" },

				lua = { "stylua" },
				python = { "ruff_format" },
				sh = { "shfmt" },
				sql = { "sqlfluff" },
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {
					lsp_fallback = true,
					timeout_ms = 500,
				}
			end,
			formatters = {
				sqlfluff = {
					args = { "format", "--dialect=postgres", "-" },
				},
			},
		},
	},
}
