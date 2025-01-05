local gf   = require('goto-ref')
local util = require('util')

vis.events.subscribe(vis.events.FILE_SAVE_PRE, function(file)
	local M = require('plugins/vis-lint')
	M.logger = function(str, level)
		if level == M.log.ERROR then
			vis:message(str)
		end
	end
	M.fixers["bibtex"] = { "bibtidy" }
	M.fixers["c"]      = { "clang-format -fallback-style=none" }
	M.fixers["cpp"]    = { "clang-format -fallback-style=none" }
	M.fixers["json"]   = { "jq --tab" }
	return M.fix(file)
end)

local logger = function(clear, ostr, estr)
	if ostr == nil and estr == nil then return end
	if clear then util.message_clear(vis) end
	if ostr  then vis:message(ostr)       end
	if estr  then vis:message(estr)       end
	vis:message(string.rep("=", vis.win.viewport.width / 2))
end

local function build_files(win)
	local build_tex = function (f)
		local cmd = "xelatex -halt-on-error -shell-escape "

		-- build in draft mode to update references
		local err, ostr = vis:pipe(cmd .. "-draftmode " .. f.name)
		if err ~= 0 then logger(true, ostr) return false end

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

	local run_python = function (f)
		local _, ostr, estr = vis:pipe('python ' .. f.name)
		logger(true, ostr, estr)
		if estr then return false end
		return true
	end

	local run_sh  = function (f)
		local _, ostr, estr = vis:pipe("$PWD/" .. f.name)
		logger(true, ostr, estr)
		gf.setup_iterators_from_text(estr, function(str)
			local result = str:find("^/usr/include") ~= nil
			result = result or str:find("^In file included")
			return result
		end)
		return true
	end

	local build_c = function (f) return run_sh({name = 'build.sh'}) end

	local lang     = {}
	lang["bash"]   = run_sh
	lang["c"]      = build_c
	lang["cpp"]    = build_c
	lang["latex"]  = build_tex
	lang["python"] = run_python

	local builder = lang[win.syntax]
	if builder == nil then
		builder = function ()
			vis:info(win.syntax .. ': filetype not supported')
			return false
		end
	end

	win:map(vis.modes.NORMAL, " c", function ()
		vis:command('X/.*/w')
		local s = "built: " .. win.file.name
		local ret, info = builder(win.file)
		if info then s = s .. " | info: " .. info end

		-- check for FIXMEs/TODOs
		local _, out = vis:pipe('ag --depth=0 --count "(FIXME|TODO)"')
		if out then
			local file_count_table = gf.generate_line_indices(out)
			local count = 0
			for i = 1, #file_count_table do
				local file, occurences = table.unpack(file_count_table[i])
				count = count + tonumber(occurences)
			end
			if count ~= 0 then s = s .. " | FIXME/TODOs: " .. tostring(count) end
		end

		if ret == true then vis:info(s) end
		return ret
	end, "build file in current window")
end
vis.events.subscribe(vis.events.WIN_OPEN, build_files)
