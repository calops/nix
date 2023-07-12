return {
	{
		"mhartington/formatter.nvim",
		event = "BufReadPost",
		enabled = false,
		config = function()
			local function prettier()
				return {
					exe = "prettier",
					args = {
						"--config-precedence",
						"prefer-file",
						vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
					},
					stdin = true,
				}
			end

			require("formatter").setup {
				logging = false,
				filetype = {
					javascript = { prettier },
					typescript = { prettier },
					markdown = { prettier },
					css = { prettier },
					json = { prettier },
					jsonc = { prettier },
					scss = { prettier },
					yaml = { prettier },
					html = { prettier },
					nix = {
						function()
							return {
								exe = "alejandra",
								args = { "-" },
								stdin = true,
							}
						end,
					},
					lua = require("formatter.filetypes.lua").stylua,
				},
			}

			vim.api.nvim_create_autocmd("BufWritePre", {
				desc = "Format on save",
				pattern = "*.nix,*.lua,*.rs",
				callback = function() vim.cmd("Format") end,
			})
		end,
	},
}
