local events_group = vim.api.nvim_create_augroup("CustomEventsHooks", {})

---@param event string
---@param callback function
local function create_hook(event, callback)
	vim.api.nvim_create_autocmd({ event }, {
		callback = callback,
		group = events_group,
	})
end

---@param callback function
local function on_colorscheme_change(callback) create_hook("ColorScheme", callback) end

return {
	on_colorscheme_change = on_colorscheme_change,
}
