local module = {}

module.map = function(mappings, opts) return require("which-key").register(mappings, opts) end

function module.reverse_table(table)
	for i = 1, math.floor(#table / 2), 1 do
		table[i], table[#table - i + 1] = table[#table - i + 1], table[i]
	end
	return table
end

return module
