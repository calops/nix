local module = {}

module.map = function(mappings, opts) return require("which-key").register(mappings, opts) end

module.reverse_table = function(table)
	for i = 1, math.floor(#table / 2), 1 do
		table[i], table[#table - i + 1] = table[#table - i + 1], table[i]
	end
	return table
end

---Helper function to help write constructors
---@generic T: table
---@param class table
---@param default T
---@return T
module.new_object = function(class, default)
	default = default or {}
	setmetatable(default, class)
	class.__index = class
	return default
end

---@generic T
---@class CachedDict<T>: { [string]: T }
---@field _cache table
CachedDict = {}

---Create a new [CachedDict<T>] object
---@generic T
---@param cacher fun(key: string): T
---@return CachedDict<T>
function CachedDict:new(cacher)
	local obj = {
		_cache = {},
	}
	setmetatable(obj, {
		__index = function(table, key)
			if key == "reset" then
				return function() table._cache = {} end
			end
			if not table._cache[key] then
				table._cache[key] = cacher(key)
			end
			return table._cache[key]
		end,
	})
	return obj
end

---Create a new lazy-loaded object
---@generic T
---@param init fun(): T
---@param reset_on_colorscheme_change boolean | nil
---@return T
-- TODO: find a way to have a proper generic class here
module.lazy_init = function(init, reset_on_colorscheme_change)
	local obj = {
		_cache = {},
	}
	setmetatable(obj, {
		__index = function(table, key)
			if key == "reset" then
				return function() table._cache = {} end
			end
			if #table._cache == 0 then
				table._cache = init()
			end
			return table._cache[key]
		end,
	})

	if reset_on_colorscheme_change then
		require("core.events").on_colorscheme_change(function() obj:reset() end)
	end

	return obj
end

---@param path string
---@param on_event fun(filename: string, events: string[], handle: uv_fs_event_t)
---@param flags table
function module.watch_file(path, on_event, flags)
	local handle = vim.uv.new_fs_event()
	assert(handle, "Failed to create fs_event handle")

	local fs_flags = {
		watch_entry = false, -- true = when dir, watch dir inode, not dir content
		stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
		recursive = false, -- true = watch dirs inside dirs
	}
	vim.tbl_extend("force", fs_flags, flags)

	-- Possibly a bug in neodev, false mismatch
	---@diagnostic disable-next-line: param-type-mismatch
	local function unwatch() handle:stop() end
	local function callback(err, filename, events)
		if err then
			error("Error in fs_event: " .. err)
			unwatch()
		else
			on_event(filename, events, handle)
		end
	end

	handle:start(path, fs_flags, callback)
	return handle
end

---@class Command
---@field cmd string[]
---@field callback fun(lines: string[])
---@field ignore_errors boolean | nil

---@param commands Command[]
---@param finally fun() | nil
function module.chain_system_commands(commands, finally)
	vim.system(commands[1].cmd, {}, function(result)
		if result.code ~= 0 and not commands[1].ignore_errors then
			vim.notify(
				"Error in system command: " .. vim.inspect(commands[1].cmd) .. "\n" .. result.stderr,
				vim.log.levels.ERROR
			)
		else
			commands[1].callback(vim.split(result.stdout, "\n", { trimempty = true }))

			if #commands > 1 then
				module.chain_system_commands(vim.list_slice(commands, 2, #commands), finally)
			elseif finally then
				finally()
			end
		end
	end)
end

---@param func fun(...)
---@param delay number | nil
---@return fun(...), uv_timer_t
function module.debounce(func, delay)
	delay = delay or 50
	local timer = vim.uv.new_timer()
	assert(timer, "Failed to create timer")

	local argv, argc
	local wrapped_fn = function(...)
		argv = argv or { ... }
		argc = argc or select("#", ...)

		timer:start(delay, 0, function()
			pcall(
				vim.schedule_wrap(function(...)
					func(...)
					timer:stop()
				end),
				unpack(argv, 1, argc)
			)
		end)
	end

	return wrapped_fn, timer
end

local sidebar_group = vim.api.nvim_create_augroup("SidebarHandler", {})
---Create a sidebar for a specific filetype
---@param pattern string
---@param condition fun(): boolean
---@return nil
function module.make_sidebar(pattern, condition)
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		pattern = pattern,
		group = sidebar_group,
		callback = function()
			if condition() and vim.wo.winfixwidth == false then
				vim.wo.statuscolumn = ""
				vim.wo.number = false
				vim.wo.foldcolumn = "0"
				vim.wo.signcolumn = "no"
				vim.cmd([[wincmd L | vert resize 80 | set winfixwidth | wincmd =]])
			end
		end,
	})
end

return module
