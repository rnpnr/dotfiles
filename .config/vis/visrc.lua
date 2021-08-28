require('vis')
require('build')
require('macros')

require('plugins/vis-spellcheck')

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme dark")
	vis:command("set ai")

	vis:command("map normal gq vip=<Escape>")
	vis:command("map normal ,f v$:|furigana<Enter><Escape>")
	vis:command("map visual ,s :|sort<Enter>")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command("set rnu")
end)
