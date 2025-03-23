local M = {}

local focus_or_open = function(file)
	local realpath = io.popen("realpath " .. file):read("*a"):sub(1, -2)
	for win in vis:windows() do
		if win.file and win.file.path == realpath then
			vis.win = win
			return
		end
	end
	vis:command(":o " .. realpath)
end

M.focus_file_at = function(file, line, col)
	if file then
		focus_or_open(file)
		vis.mode = vis.modes.NORMAL
		vis.win.selection:to(line and line or 1, col and col or 1)
	end
end

M.generate_iterators = function(file_index_table)
	local current_index = 1;

	local iterate = function(inc)
		M.focus_file_at(table.unpack(file_index_table[current_index]))
		current_index = current_index + inc
		if current_index > #file_index_table then
			current_index = 1
		end
		if current_index < 1 then
			current_index = #file_index_table
		end
	end

	local forward  = function() iterate(1)  end
	local backward = function() iterate(-1) end
	return forward, backward
end

M.generate_line_indices = function(data, filter)
	local ret = {}
	for s in data:gmatch("[^\n]*") do
		local skip = filter and filter(s)
		if not skip then
			local found, _, file, line, col = s:find('^([^:]+):([%d]+):?([%d]*):?')
			if found then table.insert(ret, {file, line, col}) end
		end
	end
	return ret
end

M.setup_iterators_from_text = function(text, filter)
	if text == nil or #text == 0 then return end
	local filepairs = M.generate_line_indices(text, filter)
	if #filepairs then
		local forward, backward = M.generate_iterators(filepairs)
		vis:map(vis.modes.NORMAL, "gn", forward)
		vis:map(vis.modes.NORMAL, "gp", backward)
	end
end

return M
