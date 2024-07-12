local colors = require("core.colors")

local severities = {
	vim.diagnostic.severity.ERROR,
	vim.diagnostic.severity.WARN,
	vim.diagnostic.severity.INFO,
	vim.diagnostic.severity.HINT,
}

--- Calls the given callback for each diagnostic severity.
--- @param callback fun(severity: number)
local function for_each_severity(callback)
	for _, severity in ipairs(severities) do
		callback(severity)
	end
end

--- @return string
local function sign(severity) return vim.diagnostic.config().signs.text[severity] end

-- TODO: types
local function sign_hl(severity) return colors.hl[vim.diagnostic.config().signs.numhl[severity]] end

-- TODO: types
local function line_hl(severity) return colors.hl[vim.diagnostic.config().signs.linehl[severity]] end

---@type integer[][]
local buffer_diags = DynamicList:new {
	event = "DiagnosticChanged",
	update_fn = function(buffers, args)
		local diagnostics = args.data.diagnostics
		local diags = {}

		for _, diag in ipairs(diagnostics) do
			local current_severity = diags[diag.lnum + 1] or 4
			diags[diag.lnum + 1] = math.min(current_severity, diag.severity)
		end

		buffers[args.buf] = diags
	end,
}

return {
	for_each_severity = for_each_severity,
	sign = sign,
	sign_hl = sign_hl,
	line_hl = line_hl,
	buffer_diags = buffer_diags,
}
