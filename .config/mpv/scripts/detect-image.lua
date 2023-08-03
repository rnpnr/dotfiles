mp.register_event("file-loaded", function()
	local fc = mp.get_property_native('estimated-frame-count')
	local tl = mp.get_property_native('track-list')
	local a = 0
	for _, t in pairs(tl) do
		a = a or t.type == "audio"
	end
	mp.set_property_native("user-data/is-image",
	                       (fc == 0 or fc == 1) and a == 0)
end)
