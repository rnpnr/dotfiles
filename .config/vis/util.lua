local util = {}

function util.splitext(file)
	if file == nil then return nil, nil end
	local i = file:reverse():find('%.')
	if i == nil then return file, nil end
	return file:sub(0, -(i + 1)), file:sub(-i)
end

function util.message_clear(vis)
	vis:message("") -- hack: focus the message window
	vis.win.file:delete(0, vis.win.file.size)
	vis:command("q")
end

-- returns a function that when called runs all functions in argv
function util.function_chain(argv)
	return function ()
		for _, f in ipairs(argv) do f() end
	end
end

-- returns a function that when called runs vis:feedkeys(keys)
function util.feedkeys(keys)
	return function ()
		vis:feedkeys(keys)
	end
end

-- returns a function that when called runs vis:command(cmd)
function util.command(cmd)
	return function()
		vis:command(cmd)
	end
end

return util
