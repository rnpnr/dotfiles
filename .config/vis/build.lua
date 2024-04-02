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
		local cmd = "xelatex -halt-on-error -shell-escape "

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

		-- check for FIXMEs
		local pos = win.selection.pos
		local info
		vis:command("x/FIXME/")
		-- pathological case: if cursor is on the end of a FIXME
		if #win.selections and pos ~= win.selection.pos then
			info = "FIXMEs: " .. tostring(#win.selections)
		end
		vis:feedkeys("<Escape><Escape>")
		win.selection.pos = pos

		-- reload pdf (zathura does this automatically)
		-- vis:command('!pkill -HUP mupdf')

		return true, info
	end
	local build_python = function (f)
		local _, ostr, estr = vis:pipe('python ' .. f.name)
		if estr then
			util.message_clear(vis)
			vis:message(estr)
			return false
		end
		if ostr then
			util.message_clear(vis)
			vis:message(ostr)
		end
		return true
	end

	local lang = {}
	lang["latex"]    = build_tex
	lang["python"]   = build_python

	local builder = lang[win.syntax]
	if builder == nil then
		builder = function ()
			vis:info(win.syntax .. ': filetype not supported')
			return false
		end
	end

	win:map(vis.modes.NORMAL, " c", function ()
			vis:command('w')
			local s = "built: " .. win.file.name
			local ret, info = builder(win.file)
			if info then s = s .. " | info: " .. info end
			if ret == true then vis:info(s) end
			return ret
		end, "build file in current window")
end
vis.events.subscribe(vis.events.WIN_OPEN, build_files)
vis:command_register("build", function ()
		vis:feedkeys(" c")
	end, "build file in current window")
