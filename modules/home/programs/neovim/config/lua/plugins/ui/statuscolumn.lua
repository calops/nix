local color_utils = require("core.colors")
local git_utils = require("core.git")
local diag_utils = require("core.diagnostics")

return {
	{
		init = function(self)
			self.bufnr = vim.fn.bufnr()
			self.severity = (diag_utils.buffer_diags[self.bufnr] or {})[vim.v.lnum]

			if require("heirline.conditions").is_active() and vim.v.lnum == vim.api.nvim_win_get_cursor(0)[1] then
				self.hl = color_utils.hl:load("CursorLineNr")
			else
				self.hl = color_utils.hl.LineNr
			end

			if self.severity then
				self.hl = diag_utils.sign_hl(self.severity)
			end

			if vim.v.virtnum ~= 0 then
				self.hl = color_utils.hl.LineNr
			end
		end,

		-- LSP diagnostics
		{
			provider = function(self) return (self.severity and diag_utils.sign(self.severity) .. " " or "  ") end,
			condition = function() return vim.v.virtnum == 0 end,
		},

		-- Line number
		{
			provider = function() return "%=" .. (vim.v.virtnum == 0 and "%l " or "┆ ") end,
		},

		-- Git chunks
		{
			init = function(self) self.extmark = (git_utils.buffer_signs[self.bufnr] or {})[vim.v.lnum] end,
			provider = function(self) return self.extmark and self.extmark.sign_text or "  " end,
			hl = function(self) return self.extmark and self.extmark.sign_hl_group or nil end,
			on_click = {
				name = "git_sign_callback",
				callback = function(_, _, _, button)
					local mouse_pos = vim.fn.getmousepos()
					vim.api.nvim_set_current_win(mouse_pos.winid)
					vim.api.nvim_win_set_cursor(mouse_pos.winid, { mouse_pos.line, 0 })

					if button == "l" then
						vim.defer_fn(require("gitsigns").preview_hunk_inline, 50)
					elseif button == "r" then
						vim.defer_fn(require("gitsigns").blame_line, 50)
					end
				end,
			},
		},
	},
}
