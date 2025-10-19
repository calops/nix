return {
	on_init = function(client, _)
		-- Turn off semantic tokens until they're more consistent
		client.server_capabilities.semanticTokensProvider = nil
		-- Turn off formatting as it tries to use nixfmt
		client.server_capabilities.documentFormattingProvider = nil
	end,
	settings = {
		nixd = { formatting = { command = nil } },
	},
}
