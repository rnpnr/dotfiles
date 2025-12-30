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

local file_exists = function(file)
	local f = io.open(file, "r")
	if f ~= nil then io.close(f) return true else return false end
end

local default_error_search = function(error_string)
	gf.setup_iterators_from_text(error_string, function(str)
		return not str:find(" error:") and not str:find(": warning:")
	end)
end

local function build_files(win)
	local build_tex = function (f)
		local cmd = "lualatex -halt-on-error -shell-escape "

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
		default_error_search(estr)
		return true
	end

	local build_c = function (f)
		local cmd
		if cmd == nil and file_exists('./build')    then cmd = '$PWD/build --debug' end
		if cmd == nil and file_exists('./build.sh') then cmd = '$PWD/build.sh'      end
		if cmd == nil and file_exists('Makefile')   then cmd = 'make'               end
		if not cmd then return false, 'failed to determine method to build' end

		local _, _, estr = vis:pipe(cmd)
		logger(true, nil, estr)
		default_error_search(estr)
		return true
	end

	local lang = {
		bash   = run_sh,
		c      = build_c,
		cpp    = build_c,
		latex  = build_tex,
		python = run_python,
		rc     = run_sh,
	}

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

local cached_command
vis:command_register("build", function(argv)
	if #argv == 0 and cached_command == nil then vis:info("build cmd [arg ...]") return false end
	if #argv ~= 0 then cached_command = table.concat(argv, " ") end

	vis:command('X/.*/w')
	vis:info("running: " .. cached_command)
	vis:redraw()
	local code, ostr, estr = vis:pipe(cached_command)
	if code ~= 0 then
		logger(true, ostr, estr)
		default_error_search(estr)
	end
end, "run command and try to collect errors")

vis.events.subscribe(vis.events.WIN_OPEN, build_files)
