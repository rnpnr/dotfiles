require('vis')
require('build')
require('macros')
require('set-title')
require('plugins/vis-gpg')

local lint = require('plugins/vis-lint')
local util = require('util')

local spell = require('plugins/vis-spellcheck')
spell.default_lang = "en_US"

local mww = 72 -- Min Window Width

-- detect matlab with %.m not objective_c
vis.ftdetect.filetypes.matlab = {}
vis.ftdetect.filetypes.matlab.ext = { "%.m$" }
assert(table.remove(vis.ftdetect.filetypes.objective_c.ext, 1) == "%.m$")

-- use smaller tabs for heavily nested matlab classes and latex
vis.ftdetect.filetypes.latex.cmd = { "set tw 4" }
vis.ftdetect.filetypes.matlab.cmd = { "set tw 4" }

vis.ftdetect.filetypes.haskell.cmd = { "set tw 4", "set expandtab true" }
lint.fixers["haskell"] = { "hindent --indent-size 4 --sort-imports" }

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme term")

	vis.options = { autoindent = true }

	local m, fk, cmd = vis.modes, util.feedkeys, util.command
	vis:map(m.NORMAL, " f", fk("v$:|furigana<Enter><Escape>"))
	vis:map(m.NORMAL, "gq", fk("vip=<Escape>"))
	vis:map(m.VISUAL, " s", cmd("|sort"))

	vis:map(m.NORMAL, "vo", cmd("x/[ \t\r]+$/ d"),
	        "remove whitespace from end of all lines")

	vis:map(m.NORMAL, " l", function()
		local ui = vis.ui
		if ui.layout == ui.layouts.HORIZONTAL then
			ui.layout = ui.layouts.VERTICAL
		else
			ui.layout = ui.layouts.HORIZONTAL
		end
	end, "swap ui layout")

	vis:map(m.NORMAL, " i", function()
		vis:message("syntax = " .. tostring(vis.win.syntax))
	end, "dump info to message window")
end)

vis:command_register("ag", function(argv)
	for _, arg in ipairs(argv) do
		local cmd = "ag " .. arg
		vis:message(cmd .. ":")
		local _, out = vis:pipe(cmd)
		vis:message(tostring(out))
	end
end, "Search for each regex in argv with the_silver_searcher")

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
			ui.layout = ui.layouts.VERTICAL
		end
	elseif tw/nw < mww then
		ui.layout = ui.layouts.HORIZONTAL
	end
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	win.options = { relativenumbers = true }
	adjust_layout(false)
end)

vis.events.subscribe(vis.events.WIN_CLOSE, function(win)
	local f, e = util.splitext(win.file.name)
	if e == '.tex' then
		vis:command("!texclean " .. f .. e)
	end
	adjust_layout(true)
end)
