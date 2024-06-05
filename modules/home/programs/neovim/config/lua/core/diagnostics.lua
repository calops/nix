local signs = require("core.symbols").signs
local hl = require("core.colors").hl
local core_utils = require("core.utils")

local severities = {
	vim.diagnostic.severity.ERROR,
	vim.diagnostic.severity.WARN,
	vim.diagnostic.severity.INFO,
	vim.diagnostic.severity.HINT,
}

local map = core_utils.lazy_init(
	function()
		return {
			[vim.diagnostic.severity.ERROR] = {
				sign = vim.diagnostic.config().signs.text[vim.diagnostic.severity.ERROR],
				hl = hl.ErrorSign,
			},
			[vim.diagnostic.severity.WARN] = {
				sign = vim.diagnostic.config().signs.text[vim.diagnostic.severity.WARN],
				hl = hl.WarnSign,
			},
			[vim.diagnostic.severity.INFO] = {
				sign = vim.diagnostic.config().signs.text[vim.diagnostic.severity.INFO],
				hl = hl.InfoSign,
			},
			[vim.diagnostic.severity.HINT] = {
				sign = vim.diagnostic.config().signs.text[vim.diagnostic.severity.HINT],
				hl = hl.HintSign,
			},
		}
	end,
	true
)

--- Calls the given callback for each severity.
--- @param callback fun(severity: number)
local function for_each_severity(callback)
	for _, severity in ipairs(severities) do
		callback(severity)
	end
end

return {
	for_each_severity = for_each_severity,
	map = map,
}
