function splitext(file)
	if file == nil then return nil, nil end
	local i = string.find(file, '%.')
	if i == nil then return file, nil end
	return string.sub(file, 0, i - 1), string.sub(file, i)
end
