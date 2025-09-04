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
					vim.g.disable_autoformat = true
				else
					vim.b.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})

			vim.api.nvim_create_user_command("FormatEnable", function(args)
				if args.bang then
					vim.g.disable_autoformat = false
				else
					vim.b.disable_autoformat = false
				end
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,

		---@module "conform"
		---@type conform.setupOpts
		opts = {
			formatters_by_ft = {
				json = { "prettierd" },
				yaml = { "prettierd" },
				html = { "prettierd" },

				lua = { "stylua" },
				sh = { "shfmt" },
				sql = { "sqlfluff" },
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = function(bufnr)
				if
					not vim.g.disable_autoformat
					and not vim.b[bufnr].disable_autoformat
					and vim.bo[bufnr].filetype ~= "nix"
				then
					return {
						lsp_format = "fallback",
						timeout_ms = 500,
					}
				end
			end,
			-- Format nix files asyncrhonously, because `nix fmt` requires slow evaluation
			format_after_save = function(bufnr)
				if
					not vim.g.disable_autoformat
					and not vim.b[bufnr].disable_autoformat
					and vim.bo[bufnr].filetype == "nix"
				then
					return {
						lsp_format = "fallback",
					}
				end
			end,
			formatters = {
				sqlfluff = {
					args = { "format", "--dialect=postgres", "-" },
				},
			},
		},
	},
}
