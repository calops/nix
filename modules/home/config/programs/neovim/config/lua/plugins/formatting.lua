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

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					---@diagnostic disable-next-line: inject-field
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})

			vim.api.nvim_create_user_command("FormatEnable", function()
				---@diagnostic disable-next-line: inject-field
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})

			map {
				["<space>f"] = { ":Format<cr>", "Format code", mode = { "n", "x" } },
			}
		end,
		opts = function()
			return {
				formatters_by_ft = {
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					json = { "prettierd" },
					yaml = { "prettierd" },

					lua = { "stylua" },
					nix = { "alejandra" },
					python = { "isort", "black" },
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
			}
		end,
	},
}
