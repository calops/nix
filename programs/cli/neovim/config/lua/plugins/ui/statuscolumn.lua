local hl_utils = require("heirline.utils")
local ui_utils = require("plugins.ui.utils")

---Create a new object
---@param class table
---@param default table
local function new_object(class, default)
	default = default or {}
	setmetatable(default, class)
	class.__index = class
	return default
end

---@class Signs
---@field diagnostics table<integer, integer>
---@field git table<integer, string>
local Signs = {}

function Signs:new()
	return new_object(self, {
		diagnostics = {},
		git = {},
	})
end

---@class CachedSigns
---@field buffers table<integer, Signs>
local CachedSigns = {}

---@return CachedSigns
function CachedSigns:new()
	return new_object(self, {
		buffers = {},
	})
end

---@param bufnr integer
---@return Signs
function CachedSigns:get(bufnr)
	if not self[bufnr] then
		self[bufnr] = Signs:new()
	end
	return self[bufnr]
end

local cached_signs = CachedSigns:new()

---@param bufnr integer
---@param diagnostics table
local function update_cached_diagnostics(bufnr, diagnostics)
	local signs = cached_signs:get(bufnr)

	signs.diagnostics = {}

	for _, diag in ipairs(diagnostics) do
		local current_severity = signs.diagnostics[diag.lnum + 1] or 4
		signs.diagnostics[diag.lnum + 1] = math.min(current_severity, diag.severity)
	end
end

---@param bufnr integer
local function update_cached_git_signs(bufnr)
	local signs = cached_signs:get(bufnr)
	local hunks = require("gitsigns").get_hunks(bufnr) or {}

	signs.git = {}

	for _, hunk in ipairs(hunks) do
		local added = hunk.added
		for i = added.start, added.start + math.max(added.count - 1, 0) do
			signs.git[i] = hunk.type
		end
	end
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function(args)
		update_cached_diagnostics(args.buf, args.data.diagnostics)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GitSignsUpdate",
	callback = function(args)
		update_cached_git_signs(args.buf)
	end,
})

return {
	{
		condition = function()
			return not vim.tbl_contains({
				"help",
				"neo-tree",
				"Trouble",
			}, vim.bo.filetype)
		end,
		static = {
			colors = {
				cursor_line = hl_utils.get_highlight("CursorLine").bg,
				cursor_num = hl_utils.get_highlight("CursorLineNr").fg,
				base = hl_utils.get_highlight("Normal").bg,
				num = hl_utils.get_highlight("LineNr").fg,
			},
			diagnostics = ui_utils.diags_sorted(),
			gitsigns = ui_utils.git(),
		},
		init = function(self)
			if require("heirline.conditions").is_active() and vim.v.lnum == vim.api.nvim_win_get_cursor(0)[1] then
				self.bg = self.colors.cursor_line
				self.fg = self.colors.cursor_num
			else
				self.bg = self.colors.base
				self.fg = self.colors.num
			end

			local signs = cached_signs:get(vim.fn.bufnr())

			local diag = signs.diagnostics[vim.v.lnum]
			if diag ~= nil then
				self.diagsign = self.diagnostics[diag]
				self.bg = self.diagsign.colors.bg
				self.fg = self.diagsign.colors.fg
			else
				self.diagsign = nil
			end

			local git_status = signs.git[vim.v.lnum]
			if git_status ~= nil then
				self.gitsign = self.gitsigns[git_status]
			else
				self.gitsign = nil
			end
		end,
		-- LSP diagnostics
		{
			provider = function(self)
				if self.diagsign ~= nil then
					return self.diagsign.sign .. " "
				else
					return "  "
				end
			end,
			condition = function()
				return vim.v.virtnum == 0
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
			provider = function(self)
				if self.gitsign then
					return self.gitsign.sign
				else
					return "  "
				end
			end,
			hl = function(self)
				local fg = self.colors.num

				if self.gitsign then
					fg = self.gitsign.colors.fg
				end

				return { fg = fg, bg = self.bg }
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
