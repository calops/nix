return {
	on_init = function(client, _)
		-- Turn off diagnostics, too many false positives
		client.server_capabilities.diagnosticsProvider = nil
	end,
}
