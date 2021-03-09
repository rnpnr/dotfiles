require('vis')
require('build')

require('plugins/vis-spellcheck')

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme dark")
	vis:command("set ai")

	vis:command("map normal gq vip=<Escape>")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command("set rnu")
end)
