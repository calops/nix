---@param name string
---@param bin string
---@param opts table
local function configure_server(name, bin, opts)
	-- check if the binary is in the path
	if vim.fn.executable(bin or name) == 0 then
		return
	end

	require("lspconfig")[name].setup(opts or {})
end

local function configure_servers(servers)
	for name, opts in pairs(servers) do
		configure_server(name, opts.bin, opts)
	end
end

return {
	configure_servers = configure_servers,
}
