util = {}
function util:splitext(file)
	if file == nil then return nil, nil end
	local i = file:reverse():find('%.')
	if i == nil then return file, nil end
	return file:sub(0, -(i + 1)), file:sub(-i)
end
