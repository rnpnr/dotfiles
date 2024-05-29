local M = {}

local focus_file = function(name)
	for win in vis:windows() do
		if win.file and win.file.name == name then
			vis.win = win
			return
		end
	end
	vis:command(":o " .. name)
end

M.generate_iterators = function(file_index_table)
	local current_index = 1;

	local iterate = function(inc)
		local file, line = table.unpack(file_index_table[current_index])
		focus_file(file)
		vis.win.selection:to(line, 1)
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

M.generate_line_indices = function(data)
	local ret = {}
	for s in data:gmatch("[^\n]*") do
		found, _, file, line = s:find('^([^:]+):([%d]+):')
		if found then table.insert(ret, {file, line}) end
	end
	return ret
end

return M
