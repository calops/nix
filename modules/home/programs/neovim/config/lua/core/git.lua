local colors = require("core.colors")
local symbols = require("core.symbols")
local core_utils = require("core.utils")

local git_signs = core_utils.lazy_init(
	function()
		return {
			add = {
				hl = colors.hl.GitSignsAdd,
				text = symbols.signs.GitSignsAdd,
			},
			change = {
				hl = colors.hl.GitSignsChange,
				text = symbols.signs.GitSignsChange,
			},
			delete = {
				hl = colors.hl.GitSignsDelete,
				text = symbols.signs.GitSignsDelete,
			},
		}
	end,
	true
)

---@class UnstagedStatus
---@field untracked number
---@field modified number
---@field deleted number
local UnstagedStatus = {}

function UnstagedStatus:new()
	return core_utils.new_object(self, {
		untracked = 0,
		modified = 0,
		deleted = 0,
	})
end

---@class StagedStatus
---@field added number
---@field modified number
---@field deleted number
local StagedStatus = {}

function StagedStatus:new()
	return core_utils.new_object(self, {
		added = 0,
		modified = 0,
		deleted = 0,
	})
end

---@alias GitFileState "modified" | "added" | "deleted" | "untracked" | "ignored" | "renamed"

---@class GitFileStatus
---@field diff_added number
---@field diff_deleted number
---@field state GitFileState
---@field staged boolean
local GitFileStatus = {}

function GitFileStatus:new()
	return core_utils.new_object(self, {
		diff_added = 0,
		diff_deleted = 0,
		state = "untracked",
		staged = false,
	})
end

---@class GitStatus
---@field is_git_repo boolean
---@field git_dir string
---@field root_dir string
---@field head string
---@field has_stash boolean
---@field unstaged UnstagedStatus
---@field staged StagedStatus
---@field files CachedDict<GitFileStatus>
---@field _watch_handles table<number, any>
local GitStatus = {}

function GitStatus:new()
	return core_utils.new_object(self, {
		is_git_repo = false,
		git_dir = "",
		root_dir = "",
		head = "",
		has_stash = false,
		unstaged = UnstagedStatus:new(),
		staged = StagedStatus:new(),
		files = CachedDict:new(function(_) return GitFileStatus:new() end),
		_watch_handles = {},
	})
end

local status_map = {
	M = "modified",
	A = "added",
	D = "deleted",
	R = "renamed",
	["?"] = "untracked",
}

GitStatus.update = core_utils.debounce(
	---@param self GitStatus
	function(self)
		self:stop_watching_git_dir()

		if self.is_git_repo then
			local stash_file = io.open(self.git_dir .. "/logs/refs/stash", "r")
			if stash_file ~= nil then
				self.has_stash = true
				stash_file:close()
			else
				self.has_stash = false
			end

			core_utils.chain_system_commands({
				{
					cmd = { "git", "status", "--porcelain", "--branch" },
					---@param lines string[]
					callback = function(lines)
						for _, line in ipairs(lines) do
							if line:sub(1, 2) == "##" then
								local branch = line:match("## ([^.]+)")
								if branch then
									self.head = branch
								end
							else
								local staged_char, unstaged_char, filename = line:match("^(.)(.)%s+(.+)")

								if staged_char and unstaged_char and filename then
									self.unstaged[unstaged_char] = (self.unstaged[unstaged_char] or 0) + 1
									self.staged[staged_char] = (self.staged[staged_char] or 0) + 1
									self.files[filename].state = status_map[unstaged_char]
									self.files[filename].staged = staged_char ~= " " and staged_char ~= "?"
								end
							end
						end
					end,
				},
				{
					cmd = { "git", "diff", "--numstat" },
					---@param lines string[]
					callback = function(lines)
						for _, line in ipairs(lines) do
							local added, deleted, filename = line:match("(%d+)%s+(%d+)%s+(.+)")
							if filename then
								self.files[filename].diff_added = tonumber(added) or 0
								self.files[filename].diff_deleted = tonumber(deleted) or 0
							end
						end
					end,
				},
			}, function()
				self:redraw()
				self:watch_git_dir()
			end)
		end
	end,
	200
)

function GitStatus:watch_git_dir()
	self:stop_watching_git_dir()

	if self.is_git_repo then
		self._watch_handles = {
			core_utils.watch_file(self.git_dir, function(_, _, _) self:update() end),
		}
	end
end

function GitStatus:stop_watching_git_dir()
	for _, handle in ipairs(self._watch_handles) do
		handle:stop()
		if not handle:is_closing() then
			handle:close()
		end
	end
	self._watch_handles = {}
end

GitStatus.init = core_utils.debounce(
	---@param self GitStatus
	function(self)
		local old_root_dir = self.root_dir
		self.git_dir = ""
		self.root_dir = ""
		core_utils.chain_system_commands({
			{
				cmd = { "git", "rev-parse", "--git-dir", "--show-toplevel" },
				ignore_errors = true,
				---@param lines string[]
				callback = function(lines)
					if #lines == 2 then
						self.is_git_repo = true
						self.root_dir = lines[2]
						self.git_dir = self.root_dir .. "/" .. lines[1]
					else
						self.is_git_repo = false
					end
				end,
			},
		}, function()
			if old_root_dir ~= self.root_dir then
				self:update()
			end
		end)
	end
)

function GitStatus:redraw()
	vim.defer_fn(function() vim.api.nvim_exec_autocmds("User", { pattern = "GitStatusUpdated" }) end, 50)
end

---@type GitStatus
local git_status = GitStatus:new()

---@class Extmark
---@field sign_text string
---@field sign_hl string

---@type integer
local gitsigns_namespace = nil

---@type Extmark[][]
local buffer_signs = {}

local function set_git_signs_for_buffer(bufnr)
	if not gitsigns_namespace then
		gitsigns_namespace = vim.api.nvim_get_namespaces().gitsigns_signs_
		if not gitsigns_namespace then
			return
		end
	end

	local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, gitsigns_namespace, { 0, 0 }, { -1, -1 }, { details = true })

	if extmarks then
		local res = {}
		for _, extmark in ipairs(extmarks) do
			local lnum = extmark[2]
			local details = extmark[4]
			res[lnum + 1] = details
		end
		buffer_signs[bufnr] = res
	else
		buffer_signs[bufnr] = nil
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "GitSignsUpdate",
	callback = function(args) set_git_signs_for_buffer(args.buf) end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GitStatusUpdated",
	callback = function()
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			set_git_signs_for_buffer(bufnr)
		end
	end,
})

vim.api.nvim_create_autocmd({ "UIEnter", "DirChanged" }, {
	callback = function() git_status:init() end,
})

return {
	signs = git_signs,
	status = git_status,
	buffer_signs = buffer_signs,
}
