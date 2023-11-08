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

module.setup = function(_)
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function() require("core.colors").reset_cache() end,
	})
end

return module
