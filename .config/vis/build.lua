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
	if (ostr == nil or #ostr == 0) and (estr == nil or #estr == 0) then return end
	if clear then util.message_clear(vis) end
	if ostr and #ostr ~= 0 then vis:message(ostr) end
	if estr and #estr ~= 0 then vis:message(estr) end
	vis:message(string.rep("=", vis.win.viewport.width / 2))
end

local file_exists = function(file)
	local f = io.open(file, "r")
	local result = f ~= nil
	if result then io.close(f) end
	return result
end

local standard_error_search = function(error_string)
	gf.setup_iterators_from_text(error_string, function(str)
		return str:find(" error:")    or
		       str:find(": note:")    or
		       str:find(": warning:")
	end)
end

local build_c_cmd = function()
	local cmd
	if cmd == nil and file_exists('./build')    then cmd = '$PWD/build --debug' end
	if cmd == nil and file_exists('./build.sh') then cmd = '$PWD/build.sh'      end
	if cmd == nil and file_exists('Makefile')   then cmd = 'make'               end
	return cmd
end

local build_c_response = function(code, out_string, error_string)
	logger(true, nil, error_string)
	standard_error_search(error_string)
	return true
end

local build_tex = function(file)
	local cmd = "lualatex -halt-on-error -shell-escape "

	-- build in draft mode to update references
	local err, ostr = vis:pipe(cmd .. "-draftmode " .. file.name)
	if err ~= 0 then logger(true, ostr) return false end

	local fp = util.splitext(file.name)
	-- update refrences
	vis:command("!biber " .. fp .. " >/dev/null")
	-- update nomenclature
	-- vis:command("!makeindex " .. fp .. ".nlo -s nomencl.ist -o " .. fp .. ".nls >/dev/null")
	-- update glossary
	-- vis:command("!makeglossaries " .. fp .. " >/dev/null")

	-- build actual pdf
	err = vis:pipe(cmd .. file.name)
	if err ~= 0 then return false end

	-- reload pdf (zathura does this automatically)
	-- vis:command('!pkill -HUP mupdf')

	return true
end

local run_python_cmd = function(file) return 'python ' .. file.name end
local run_python_response = function(code, out_string, error_string)
	logger(true, out_string, error_string)
	if error_string ~= '' then return false end
	return true
end

local run_sh_cmd = function(file) return "$PWD/" .. file.name end
local run_sh_response = function(code, out_string, error_string)
	logger(true, out_string, error_string)
	standard_error_search(error_string)
	return true
end

local current_build_id = 0
local current_build
vis:command_register("build_kill", function()
	current_build = nil
end, "kill currently running build")

vis.events.subscribe(vis.events.PROCESS_RESPONSE, function(name, event, code, message)
	if not current_build or current_build.name ~= name then
		return
	end

	if event == "STDOUT" then
		current_build.out = current_build.out .. message
	end

	if event == "STDERR" then
		current_build.error = current_build.error .. message
	end

	if event == "EXIT" or event == "SIGNAL" then
		local build = current_build
		current_build = nil

		local result, info = build.response(code, build.out, build.error)
		local s = "build: completed (" .. code .. ")"
		if info then s = s .. " | info: " .. info end
		if result == true then vis:info(s) end
	end
end)

local launch_command = function(command, response_handler)
	if current_build then
		vis:info("build already running; :build_kill to kill")
		return false
	end

	vis:command('X/.*/w')
	local name = 'build{' .. current_build_id .. '}'
	current_build_id = current_build_id + 1
	local build_fd = vis:communicate(name, command)
	current_build = {name = name, fd = build_fd, out = '', error = '', response = response_handler}
	vis:info("build: starting: ".. command)
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	local lang = {
		bash   = {command = run_sh_cmd,     response = run_sh_response    },
		rc     = {command = run_sh_cmd,     response = run_sh_response    },
		c      = {command = build_c_cmd,    response = build_c_response   },
		cpp    = {command = build_c_cmd,    response = build_c_response   },
		python = {command = run_python_cmd, response = run_python_response},
		latex  = build_tex,
	}

	local builder = lang[win.syntax]
	local binding, command
	if builder ~= nil and type(builder) == 'function' then
		binding = function() builder(win.file) end
	elseif builder ~= nil then
		if builder ~= nil then command = builder.command(win.file) end
		if command == nil then
			binding = function() vis:info("build: missing command for filetype: " .. win.syntax) end
		else
			binding = function() launch_command(command, builder.response) end
		end
	end
	win:map(vis.modes.NORMAL, " c", binding, "build file in current window")
end)

local cached_command
vis:command_register("build", function(argv)
	if #argv == 0 and cached_command == nil then vis:info("build cmd [arg ...]") return false end

	if #argv ~= 0 then cached_command = table.concat(argv, " ") end
	launch_command(cached_command, function(code, out_string, error_string)
		if code ~= 0 then
			logger(true, ostr, estr)
			standard_error_search(estr)
		end
		return true
	end)
end, "run command and try to collect errors")

vis:command_register("todo", function()
	local _, out = vis:pipe('ag --depth=0 --count "(FIXME|TODO)"')
	local count = 0
	if out then
		local file_count_table = gf.generate_line_indices(out)
		for i = 1, #file_count_table do
			local file, occurences = table.unpack(file_count_table[i])
			count = count + tonumber(occurences)
		end
	end
	if count ~= 0 then
		local _, out = vis:pipe('ag --depth=0 "(FIXME|TODO)"')
		logger(true, out)
		standard_error_search(out)
	end
	vis:info("Found TODOs: " .. tostring(count))
end, "search for TODOs in codebase")
