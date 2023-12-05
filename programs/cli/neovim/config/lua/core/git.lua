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
---@field root string
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
		root = "",
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
	100,
	---@param self GitStatus
	function(self)
		if self.is_git_repo then
			local stash_file = io.open(self.root .. "/logs/refs/stash", "r")
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
			}, function() self:redraw() end)
		end
	end
)

function GitStatus:watch_git_files()
	for _, handle in ipairs(self._watch_handles) do
		---@diagnostic disable-next-line: param-type-mismatch
		handle:stop()
		if not handle:is_closing() then
			handle:close()
		end
	end
	self._watch_handles = {}
	if self.is_git_repo then
		self._watch_handles = {
			core_utils.watch_file(self.root .. "/logs/refs", function(_, _, _) self:update() end, { recursive = true }),
		}
	end
end

function GitStatus:init()
	local old_root = self.root
	local new_root = ""
	vim.system({ "git", "rev-parse", "--git-dir" }, {}, function(result)
		if result.code == 0 then
			new_root = result.stdout:gsub("\n", "")
		end
		if old_root ~= new_root then
			self.is_git_repo = new_root ~= ""
			self.root = new_root
			self:watch_git_files()
			self:update()
		end
	end)
end

function GitStatus:redraw()
	vim.defer_fn(function() vim.api.nvim_exec_autocmds("User", { pattern = "GitStatusUpdated" }) end, 50)
end

---@type GitStatus
local git_status = GitStatus:new()

vim.api.nvim_create_autocmd({ "UIEnter", "DirChanged" }, {
	callback = function() git_status:init() end,
})

return {
	signs = git_signs,
	status = git_status,
}
