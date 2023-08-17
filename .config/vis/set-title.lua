local function set_title(s)
	vis:command("!printf '\\033]2;vis: " .. s .. "\\007'")
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	set_title(win.file.name or "[No Name]")
end)

vis.events.subscribe(vis.events.FILE_SAVE_POST, function(file, path)
	set_title(file.name)
end)

vis.events.subscribe(vis.events.QUIT, function()
	vis:message("")
	vis:command("!tput reset")
end)
