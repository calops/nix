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
	callback = function(args) update_cached_diagnostics(args.buf, args.data.diagnostics) end,
})

-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "GitSignsUpdate",
-- 	callback = function(args) update_cached_git_signs(args.buf) end,
-- })
--
-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "GitStatusUpdated",
-- 	callback = function() core_utils.for_all_buffers(update_cached_git_signs) end,
-- })

local gitsigns_namespace = nil

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
			gitsigns = git_utils.signs,
		},
		init = function(self)
			local bufnr = vim.fn.bufnr()
			if not bufnr then
				return
			end

			if require("heirline.conditions").is_active() and vim.v.lnum == vim.api.nvim_win_get_cursor(0)[1] then
				self.hl = color_utils.hl.CursorLineNr
			else
				self.hl = color_utils.hl.LineNr
			end

			local signs = cached_signs:get(bufnr)

			local diag = signs.diagnostics[vim.v.lnum]
			if diag ~= nil then
				self.severity = diag
				self.hl = diag_utils.sign_hl(self.severity)
			else
				self.severity = nil
			end

			local git_status = signs.git[vim.v.lnum]
			if git_status ~= nil then
				self.gitsign = self.gitsigns[git_status]
			else
				self.gitsign = nil
			end

			if not gitsigns_namespace then
				gitsigns_namespace = vim.api.nvim_get_namespaces().gitsigns_signs_
			end
		end,

		-- LSP diagnostics
		{
			provider = function(self)
				if self.severity ~= nil then
					return diag_utils.sign(self.severity) .. " "
				else
					return "  "
				end
			end,
			condition = function() return vim.v.virtnum == 0 end,
			hl = function(self) return self.severity and diag_utils.sign_hl(self.severity) or nil end,
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
		},

		-- Git chunks
		{
			init = function(self)
				if gitsigns_namespace then
					local extmarks = vim.api.nvim_buf_get_extmarks(
						0,
						gitsigns_namespace,
						{ vim.v.lnum - 1, 0 },
						{ vim.v.lnum - 1, -1 },
						{ details = true }
					)
					if extmarks and extmarks[1] then
						self.extmark = extmarks[1][4]
					else
						self.extmark = nil
					end
				end
			end,
			provider = function(self)
				if self.extmark then
					return self.extmark.sign_text
				else
					return "  "
				end
			end,
			hl = function(self)
				if self.extmark then
					return self.extmark.sign_hl_group
				else
					return nil
				end
			end,
			on_click = {
				name = "git_sign_callback",
				callback = function(_, _, _, button)
					local mouse_pos = vim.fn.getmousepos()
					if not mouse_pos then
						return
					end
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
