if pcall(require, ".nvim.nixd") then
	vim.defer_fn(function() vim.notify("nixd settings loaded", "info") end, 500)
end

vim.g.lazydev_enabled = true
