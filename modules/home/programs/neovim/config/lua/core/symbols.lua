require("core.utils")

local cached_signs = CachedDict:new(function(key)
	return vim.fn.sign_getdefined(key)[1].text ---@type string
end)

return {
	signs = cached_signs,
}
