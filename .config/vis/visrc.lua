require('vis')
require('build')
require('macros')
require('set-title')
require('plugins/vis-gpg')
require('plugins/vis-spellcheck')

local lint = require('plugins/vis-lint')
local gf   = require('goto-ref')
local util = require('util')
local highlight = require('highlight')
highlight.keywords = {
	NOCOMMIT  = 'fore:cyan,underlined,bold,blink',
	FIXME     = 'fore:red,underlined,bold',
	NOTE      = 'fore:green,underlined,bold',
	TODO      = 'fore:magenta,underlined,bold',
	IMPORTANT = 'fore:yellow,underlined,bold',
}

local mww = 72 -- Min Window Width

-- detect matlab with %.m not objective_c
vis.ftdetect.filetypes.matlab = { ext = { "%.m$" } }
assert(table.remove(vis.ftdetect.filetypes.objective_c.ext, 1) == "%.m$")

-- use smaller tabs for heavily nested matlab classes and latex
vis.ftdetect.filetypes.latex.cmd  = { "set tw 4" }
vis.ftdetect.filetypes.matlab.cmd = { "set tw 4" }

vis.ftdetect.filetypes.haskell.cmd = { "set tw 4", "set expandtab true" }
lint.fixers["haskell"] = { "hindent --indent-size 4 --sort-imports" }

lint.fixers["python"] = {} -- {"black -l 80 -q -"}
vis.ftdetect.filetypes.python.cmd = { "set tw 4", "set expandtab true" }

vis.ftdetect.filetypes.yaml.cmd = { "set tw 2", "set expandtab true" }

vis.events.subscribe(vis.events.INIT, function()
	vis:command("set theme term")

	vis.options = { autoindent = true }

	local m, cmd = vis.modes, util.command
	vis:map(m.NORMAL, " f", "v$:|furigana<Enter><Escape>")
	vis:map(m.NORMAL, " j", "<vis-window-next>")
	vis:map(m.NORMAL, " k", "<vis-window-prev>")
	vis:map(m.NORMAL, "gq", "vip=<Escape>")
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
		local fn = vis.win.file.name
		vis:message("syntax = " .. tostring(vis.win.syntax))
		vis:message("file.name = " .. fn)
	end, "dump info to message window")
end)

vis:command_register("ag", function(argv)
	util.message_clear(vis)
	local outstr = ""
	for _, arg in ipairs(argv) do
		local _, out = vis:pipe("ag -Q --column " .. arg)
		if out then
			vis:message(out)
			outstr = outstr .. out
		end
	end
	gf.setup_iterators_from_text(outstr)
end, "Search for each literal in argv with the_silver_searcher")

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	win.options = {
		colorcolumn = 100,
		relativenumbers = true,
	}

	local m, cmd = vis.modes, util.command
	-- pass some args to fmt(1)
	local fmtcmd = ":|fmt -l %d -w 66"
	local fmt = cmd(fmtcmd:format(win.options.tabwidth))
	win:map(m.NORMAL, "=", fmt)
	win:map(m.VISUAL, "=", fmt)
end)

vis.events.subscribe(vis.events.WIN_CLOSE, function(win)
	local f, e = util.splitext(win.file.name)
	if e == '.tex' then
		vis:command("!texclean " .. f .. e)
	end
end)
