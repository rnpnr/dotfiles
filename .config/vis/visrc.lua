require('vis')
require('build')
require('macros')

spell = require('plugins/vis-spellcheck')
spell.lang = "en_US"

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme dark")
	vis:command("set ai")

	vis:command("map normal gq vip=<Escape>")
	vis:command("map normal ,f v$:|furigana<Enter><Escape>")
	vis:command("map visual ,s :|sort<Enter>")

	vis:map(vis.modes.NORMAL, "vo", function()
			vis:command("x/[ \t\r]+$/ d")
		end, "remove spaces, tabs, and \r from end of all lines")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command("set rnu")
end)
