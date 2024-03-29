local util = require('util')

local function fmt_file(file)
	local M = require('plugins/vis-lint')
	M.logger = function(str, level)
		if level == M.log.ERROR then
			vis:message(str)
		end
	end
	M.fixers["ansi_c"] = { "clang-format -fallback-style=none" }
	M.fixers["cpp"] = { "clang-format -fallback-style=none" }
	M.fixers["bibtex"] = { "bibtidy" }
	M.fixers["json"] = { "jq --tab" }
	return M.fix(file)
end
vis.events.subscribe(vis.events.FILE_SAVE_PRE, fmt_file)

local function build_files(win)
	local build_tex = function (f)
		local cmd = "pdflatex -halt-on-error -shell-escape "

		-- build in draft mode to update references
		local err, ostr = vis:pipe(cmd .. "-draftmode " .. f.name)
		if err ~= 0 then
			if ostr then
				util.message_clear(vis)
				vis:message(ostr)
			end
			return false
		end

		local fp = util.splitext(f.name)
		-- update refrences
		vis:command("!biber " .. fp .. " >/dev/null")
		-- update glossary
		-- vis:command("!makeglossaries " .. fp .. " >/dev/null")

		-- build actual pdf
		err = vis:pipe(cmd .. f.name)
		if err ~= 0 then return false end

		-- reload pdf (zathura does this automatically)
		-- vis:command('!pkill -HUP mupdf')

		return true
	end

	local lang = {}
	lang["latex"]    = build_tex

	local builder = lang[win.syntax]
	if builder == nil then
		builder = function ()
			vis:info(win.syntax .. ': filetype not supported')
			return false
		end
	end

	win:map(vis.modes.NORMAL, " c", function ()
			vis:command('w')
			vis:info("building: " .. win.file.name)
			return builder(win.file)
		end, "build file in current window")
end
vis.events.subscribe(vis.events.WIN_OPEN, build_files)
vis:command_register("build", function ()
		vis:feedkeys(" c")
	end, "build file in current window")
