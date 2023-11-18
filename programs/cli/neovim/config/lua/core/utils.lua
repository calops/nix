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

module.with_reset = function(constructor) end

return module
