local events_group = vim.api.nvim_create_augroup("CustomEventsHooks", {})

---@param event string
---@param callback function
local function create_hook(event, callback, opts)
	opts = vim.tbl_extend("force", { group = events_group }, opts or {})
	require("core.utils").aucmd(event, callback, opts)
end

---@param callback function
local function on_colorscheme_change(callback) create_hook("ColorScheme", callback) end

---@param callback function
---@param filetype string
local function on_filetype(filetype, callback)
	create_hook("BufReadPre", callback, { pattern = "*." .. filetype, once = true })
end

return {
	on_colorscheme_change = on_colorscheme_change,
	on_filetype = on_filetype,
}
