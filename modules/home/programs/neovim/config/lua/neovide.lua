if not vim.g.neovide then
	return
end

vim.g.neovide_floating_blur_amount_x = 1.5
vim.g.neovide_floating_blur_amount_y = 1.5
vim.g.neovide_floating_corner_radius = 0.5
vim.g.neovide_scroll_animation_length = 0.13
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5
vim.g.neovide_unlink_border_highlights = true
vim.g.neovide_refresh_rate = 60
vim.g.neovide_cursor_smooth_blink = true
vim.g.neovide_underline_stroke_scale = 2.0
vim.g.experimental_layer_grouping = true

local function set_scale(scale)
	vim.g.neovide_scale_factor = scale
	-- Force redraw, otherwise the scale change won't be rendered until the next UI update
	vim.cmd.redraw { bang = true }
end

vim.keymap.set("n", "<C-+>", function() set_scale(vim.g.neovide_scale_factor + 0.1) end)
vim.keymap.set("n", "<C-->", function() set_scale(vim.g.neovide_scale_factor - 0.1) end)
vim.keymap.set("n", "<C-0>", function() set_scale(1.0) end)
