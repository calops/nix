local colors = require("core.colors")
local symbols = require("core.symbols")
local core_utils = require("core.utils")

local git_signs = {
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

---@class GitStatus
---@field is_git_repo boolean
---@field root string
---@field head string
---@field has_stash boolean
---@field unstaged UnstagedStatus
---@field staged StagedStatus
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
		_watch_handles = {},
	})
end

---@type table<string, string[]>
local commands = {
	git_status = { "git", "status", "--porcelain", "--branch" },
	git_diff = { "git", "diff", "--numstat" },
}
local status_map = {
	M = "modified",
	A = "added",
	D = "deleted",
	R = "modified",
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
					cmd = commands.git_status,
					callback = function(lines)
						for _, line in ipairs(lines) do
							if line:sub(1, 2) == "##" then
								local branch = line:match("## ([^.]+)")
								if branch then
									self.head = branch
								end
							else
								local status_code = status_map[line:sub(2, 2)]
								if status_code then
									self.unstaged[status_code] = (self.unstaged[status_code] or 0) + 1
								end
							end
						end
					end,
				},
				{
					cmd = commands.git_diff,
					callback = function(lines)
						for _, line in ipairs(lines) do
							local added, deleted, filename = line:match("(%d+)%s+(%d+)%s+(.+)")
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
