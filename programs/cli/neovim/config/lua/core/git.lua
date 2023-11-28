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

---@class StagedStatus
---@field added number
---@field modified number
---@field deleted number

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
		unstaged = {
			untracked = 0,
			modified = 0,
			deleted = 0,
		},
		staged = {
			added = 0,
			modified = 0,
			deleted = 0,
		},
		_watch_handles = {},
	})
end

function GitStatus:update()
	if self.root then
		local refs_dir = self.root .. "/logs/refs"
		self.has_stash = io.open(refs_dir .. "/stash", "r") ~= nil
		-- self.head = nil

		local status_map = {
			M = "modified",
			A = "added",
			D = "deleted",
			R = "modified",
			["?"] = "untracked",
		}
		local status = {
			untracked = 0,
			modified = 0,
			added = 0,
			deleted = 0,
		}
		vim.system({ "git", "status", "--porcelain", "--branch" }, {}, function(result)
			if result.code == 0 then
				for line in vim.gsplit(result.stdout, "\n", { trimempty = true }) do
					if line:sub(1, 2) == "##" then
						local branch = line:match("## ([^.]+)")
						if branch then
							self.head = branch
						end
					end
					local status_code = status_map[line:sub(2, 2)]
					if status_code then
						status[status_code] = status[status_code] + 1
					end
				end
			else
				vim.notify("Failed to get git status:\n" .. result.stderr, vim.log.levels.ERROR)
			end
			self:redraw()
		end)
	end
end

function GitStatus:watch_git_files()
	for _, handle in ipairs(self._watch_handles) do
		---@diagnostic disable-next-line: param-type-mismatch
		handle:stop()
		if not handle:is_closing() then
			handle:close()
		end
	end
	self._watch_handles = {}
	if self.root then
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
