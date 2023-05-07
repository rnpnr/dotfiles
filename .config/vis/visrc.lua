require('vis')
require('build')
require('macros')
require('plugins/vis-gpg')
require('plugins/vis-lint')

local util = require('util')

local spell = require('plugins/vis-spellcheck')
spell.default_lang = "en_US"

local mww = 72 -- Min Window Width

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme term")
	vis:command("set ai")

	vis:command("map normal gq vip=<Escape>")
	vis:command("map normal ,f v$:|furigana<Enter><Escape>")
	vis:command("map visual ,s :|sort<Enter>")

	vis:map(vis.modes.NORMAL, "vo", function()
		vis:command("x/[ \t\r]+$/ d")
	end, "remove spaces, tabs, and \r from end of all lines")

	vis:map(vis.modes.NORMAL, ",l", function()
		local ui = vis.ui
		if ui.layout == ui.layouts.HORIZONTAL then
			ui:arrange(ui.layouts.VERTICAL)
		else
			ui:arrange(ui.layouts.HORIZONTAL)
		end
	end, "swap ui layout")
end)

local function adjust_layout(wclose)
	local ui = vis.ui
	local tw, nw = 0, 0
	for w in vis:windows() do
		tw = tw + w.width
		nw = nw + 1
	end
	if wclose == true then nw = nw - 1 end
	if ui.layout == ui.layouts.HORIZONTAL then
		if vis.win.width > nw * mww then
			ui:arrange(ui.layouts.VERTICAL)
		end
	elseif tw/nw < mww then
		ui:arrange(ui.layouts.HORIZONTAL)
	end
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command("set rnu")
	adjust_layout(false)
end)

vis.events.subscribe(vis.events.WIN_CLOSE, function(win)
	local f, e = util.splitext(win.file.name)
	if e == '.tex' then
		vis:command("!texclean " .. f .. e)
	end
	adjust_layout(true)
end)
