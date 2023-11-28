local module = {}

module.map = function(mappings, opts) return require("which-key").register(mappings, opts) end

module.reverse_table = function(table)
	for i = 1, math.floor(#table / 2), 1 do
		table[i], table[#table - i + 1] = table[#table - i + 1], table[i]
	end
	return table
end

---Helper function to help write constructors
---@param class table
---@param default table
module.new_object = function(class, default)
	default = default or {}
	setmetatable(default, class)
	class.__index = class
	return default
end

---@class CachedDict<T>: { [string]: T }

---Create a new [CachedDict<T>] object
---@generic T
---@param cacher fun(key: string): T
---@return CachedDict<T>
module.new_cached_dict = function(cacher)
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
---@field cmd table<string>
---@field callback fun(lines: table<string>)

---@param commands table<Command>
---@param finally fun() | nil
function module.chain_system_commands(commands, finally)
	vim.system(commands[1].cmd, {}, function(result)
		if result.code ~= 0 then
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

return module
