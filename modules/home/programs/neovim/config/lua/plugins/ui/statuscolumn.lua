local core_utils = require("core.utils")
local color_utils = require("core.colors")
local git_utils = require("core.git")
local diag_utils = require("core.diagnostics")

---@class Signs
---@field diagnostics table<integer, integer>
---@field git table<integer, string>
local Signs = {}

function Signs:new()
	return core_utils.new_object(self, {
		diagnostics = {},
		git = {},
	})
end

---@class CachedSigns
---@field buffers table<integer, Signs>
local CachedSigns = {}

---@return CachedSigns
function CachedSigns:new()
	return core_utils.new_object(self, {
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

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function(args) update_cached_diagnostics(args.buf, args.data.diagnostics) end,
})

local gitsigns_namespace = nil

return {
	{
		init = function(self)
			self.bufnr = vim.fn.bufnr()

			if require("heirline.conditions").is_active() and vim.v.lnum == vim.api.nvim_win_get_cursor(0)[1] then
				self.hl = color_utils.hl:load("CursorLineNr")
			else
				self.hl = color_utils.hl.LineNr
			end

			local signs = cached_signs:get(self.bufnr)
			local diag = signs.diagnostics[vim.v.lnum]

			if diag ~= nil then
				self.severity = diag
				self.hl = diag_utils.sign_hl(self.severity)
			else
				self.severity = nil
			end

			if not gitsigns_namespace then
				gitsigns_namespace = vim.api.nvim_get_namespaces().gitsigns_signs_
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
