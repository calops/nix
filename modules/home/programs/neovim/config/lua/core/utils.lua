local function map(mappings, opts) return require("which-key").register(mappings, opts) end

---Helper function to help write constructors
---@generic T: table
---@param class table
---@param default T
---@return T
local function new_object(class, default)
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
local function lazy_init(init, reset_on_colorscheme_change)
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
---@param flags? table
local function watch_file(path, on_event, flags)
	local handle = assert(vim.uv.new_fs_event(), "Failed to create fs_event handle")

	handle:start(path, flags or {}, function(err, filename, events)
		if err then
			error("Error in fs_event: " .. err)
			handle:stop()
		else
			on_event(filename, events, handle)
		end
	end)

	return handle
end

---@class MyCommand
---@field cmd string[]
---@field callback fun(lines: string[])
---@field ignore_errors boolean | nil

---@param commands MyCommand[]
---@param finally fun() | nil
local function chain_system_commands(commands, finally)
	vim.system(commands[1].cmd, {}, function(result)
		if result.code ~= 0 and not commands[1].ignore_errors then
			vim.notify(
				"Error in system command: " .. vim.inspect(commands[1].cmd) .. "\n" .. result.stderr,
				vim.log.levels.ERROR
			)
			if finally then
				finally()
			end
		else
			commands[1].callback(vim.split(result.stdout, "\n", { trimempty = true }))

			if #commands > 1 then
				chain_system_commands(vim.list_slice(commands, 2, #commands), finally)
			elseif finally then
				finally()
			end
		end
	end)
end

---@param func fun(...)
---@param delay? number
---@return fun(...), uv_timer_t
local function debounce(func, delay)
	delay = delay or 50
	local timer = vim.uv.new_timer()

	local wrapped_fn = function(...)
		local argv = { ... }
		local argc = select("#", ...)

		timer:start(delay, 0, function() pcall(vim.schedule_wrap(func), unpack(argv, 1, argc)) end)
	end

	return wrapped_fn, timer
end

---Run a function for all buffers, and aggregate the results
---@generic T
---@param func fun(bufnr: number): T
---@return T[]
local function for_all_buffers(func)
	local ret = {}

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		table.insert(ret, 0, func(bufnr))
	end

	return ret
end
---
---@generic T
---@param list [T]
local function empty_list(list)
	-- Fastest way to empty a list in lua
	local count = #list
	for i = 0, count do
		list[i] = nil
	end
end

---@generic T
---@class DynamicList<T>: [T]
DynamicList = {}

---@generic T
---@class DynamicListOpts<T>
---@diagnostic disable-next-line: undefined-doc-name
---@field update_fn fun(list: DynamicList<T>, args: any)
---@field event? string
---@field pattern? string
DynamicListOpts = {}

---@generic T
---@param opts DynamicListOpts
---@return DynamicList<T>
function DynamicList:new(opts)
	local list = {}

	if opts.event then
		vim.api.nvim_create_autocmd(opts.event, {
			pattern = opts.pattern,
			callback = function(args) opts.update_fn(list, args) end,
		})
	end

	return list
end

return {
	map = map,
	lazy_init = lazy_init,
	debounce = debounce,
	chain_system_commands = chain_system_commands,
	new_object = new_object,
	watch_file = watch_file,
	for_all_buffers = for_all_buffers,
}
