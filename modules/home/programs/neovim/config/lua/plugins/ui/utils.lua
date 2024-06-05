local colors = require("core.colors")

local separators = {
	left = "",
	left_lite = "",
	right = "",
	right_lite = "",
}

local function fmt(color)
	if type(color) == "string" then
		return color
	elseif type(color) == "number" then
		return string.format("#%x", color)
	end
end

local function build_pill(left, center, right, key, opts)
	key = key or "provider"
	local result = {
		insert = function(self, item)
			if opts then
				vim.tbl_extend("force", item, opts)
			end
			table.insert(self.content, item)
		end,
		content = {},
	}
	local function bg(color)
		if not color then
			color = {}
		end

		if not color.bg then
			local fg = color.fg
			if not fg then
				fg = colors.palette().text
			end
			color.bg = colors.darken(fmt(fg), 0.3)
		end

		return fmt(color.bg)
	end

	local prev_color = colors.hl.Normal
	for i, item in ipairs(left) do
		if not item.condition or item.condition() then
			local lite = item.lite and i > 1
			result:insert {
				[key] = lite and separators.left_lite or separators.left,
				hl = {
					fg = lite and colors.palette().base or bg(item.hl),
					bg = bg(prev_color),
				},
			}
			result:insert(item)
			prev_color = item.hl
		end
	end

	result:insert { [key] = separators.left, hl = { fg = bg(center.hl), bg = bg(prev_color) } }
	result:insert(center)
	prev_color = center.hl

	for _, item in ipairs(right) do
		if not item.condition or item:condition() then
			result:insert { [key] = separators.right, hl = { fg = bg(prev_color), bg = bg(item.hl) } }
			result:insert(item)
			prev_color = item.hl
		end
	end

	result:insert { [key] = separators.right, hl = { fg = bg(prev_color), bg = bg(colors.hl.Normal) } }

	return result.content
end

local function diag_count_for_buffer(bufnr, diag_count)
	if not diag_count then
		diag_count = { 0, 0, 0, 0 }
	end

	for _, diag in ipairs(vim.diagnostic.get(bufnr)) do
		diag_count[diag.severity] = diag_count[diag.severity] + 1
	end

	return diag_count
end

local function make_tablist(tab_component)
	return {
		init = function(self)
			local tabpages = vim.api.nvim_list_tabpages()
			for i, tabpage in ipairs(tabpages) do
				local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
				local child = self[i]
				if not (child and child.tabpage == tabpage) then
					self[i] = self:new(tab_component, i)
					child = self[i]
					child.tabnr = tabnr
					child.tabpage = tabpage
				end
				if tabpage == vim.api.nvim_get_current_tabpage() then
					child.is_active = true
					self.active_child = i
				else
					child.is_active = false
				end
			end
			if #self > #tabpages then
				for i = #self, #tabpages + 1, -1 do
					self[i] = nil
				end
			end
		end,
	}
end

return {
	build_pill = build_pill,
	diag_count_for_buffer = diag_count_for_buffer,
	make_tablist = make_tablist,
}
