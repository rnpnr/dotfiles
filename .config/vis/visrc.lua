require('vis')

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme dark")
	vis:command("set ai")
end)