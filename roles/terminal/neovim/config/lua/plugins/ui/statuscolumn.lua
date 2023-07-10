local utils = require("heirline.utils")
local ui_utils = require("plugins.ui.utils")

return {
	{
		condition = function()
			if vim.tbl_contains({
				"help",
				"neo-tree",
				"Trouble",
			}, vim.bo.filetype) then
				return false
			end

			return true
		end,
		static = {
			colors = {
				cursor_line = utils.get_highlight("CursorLine").bg,
				cursor_num = utils.get_highlight("CursorLineNr").fg,
				base = utils.get_highlight("Normal").bg,
				num = utils.get_highlight("LineNr").fg,
			},
			diagnostics = ui_utils.diags_signs(),
		},
		init = function(self)
			if require("heirline.conditions").is_active() and vim.v.lnum == vim.api.nvim_win_get_cursor(0)[1] then
				self.bg = self.colors.cursor_line
				self.fg = self.colors.cursor_num
			else
				self.bg = self.colors.base
				self.fg = self.colors.num
			end

			-- TODO: call this once for the whole file and cache results
			self.signs = vim.fn.sign_getplaced(vim.fn.bufnr(), { lnum = vim.v.lnum, group = "*" })[1].signs

			self.diagsign = nil
			for _, sign in ipairs(self.signs) do
				local diagsign_name = sign.name:match("DiagnosticSign.*")
				if diagsign_name then
					local diag = self.diagnostics[diagsign_name]
					if not self.diagsign or diag.severity < self.diagsign.severity then
						self.diagsign = diag
						self.bg = diag.colors.bg
						self.fg = diag.colors.fg
					end
				end
			end
		end,
		-- LSP diagnostics
		{
			condition = function()
				return vim.v.virtnum == 0
			end,
			provider = function(self)
				if self.diagsign then
					return self.diagsign.sign .. " "
				else
					return "   "
				end
			end,
			hl = function(self)
				local fg = self.fg
				local bg = self.bg

				if self.diagsign then
					fg = self.diagsign.colors.fg
				end

				return { fg = fg, bg = bg }
			end,
		},
		-- Line number
		{
			provider = function()
				local num = "%l "
				if vim.v.virtnum ~= 0 then
					num = "┆ "
				end
				return "%=" .. num
			end,
			hl = function(self)
				return { fg = self.fg, bg = self.bg }
			end,
		},
		-- Git chunks
		{
			condition = require("heirline.conditions").is_git_repo,
			init = function(self)
				for _, sign in ipairs(self.signs) do
					self.gitsign = sign.name:match("GitSigns.*")
					if self.gitsign then
						return
					end
				end
				self.gitsign = nil
			end,
			provider = function(self)
				if self.gitsign == "GitSignsUntrackedUntracked" then
					return "┋ "
				elseif self.gitsign then
					return "┃ "
				else
					return "  "
				end
			end,
			hl = function(self)
				local fg = self.colors.num
				local bg = self.bg

				if self.gitsign then
					fg = ui_utils.get_hl(self.gitsign).fg
				end

				return { fg = fg, bg = bg }
			end,
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
