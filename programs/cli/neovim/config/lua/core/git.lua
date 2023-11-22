local colors = require("core.colors")
local symbols = require("core.symbols")

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

return {
	signs = git_signs,
}
