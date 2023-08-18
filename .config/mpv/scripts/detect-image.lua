mp.register_event("file-loaded", function()
	local fc = mp.get_property_native('estimated-frame-count')
	local tl = mp.get_property_native('track-list')
	local a = 0
	for _, t in pairs(tl) do
		a = a or t.type == "audio"
	end
	local isimg = (fc == 0 or fc == 1) and a == 0
	mp.set_property_native("user-data/is-image", isimg)
	if isimg then
		mp.commandv("enable-section", "image")
	else
		mp.commandv("disable-section", "image")
	end
end)
