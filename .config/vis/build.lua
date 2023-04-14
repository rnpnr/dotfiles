require('util')

local function fmt_file(file)
	local win = vis.win
	local fmt = {}
	fmt["ansi_c"] = "clang-format -fallback-style=none"
	fmt["cpp"] = "clang-format -fallback-style=none"
	fmt["bibtex"] = "bibtidy"

	local cmd = fmt[win.syntax]
	if cmd == nil then return end

	local err, ostr, estr = vis:pipe(file, {start = 0, finish = file.size}, cmd)
	if err ~= 0 then
		if estr then vis:message(estr) end
		return false
	end

	local pos = win.selection.pos
	file:delete(0, file.size)
	file:insert(0, ostr)
	win.selection.pos = pos
	return true
end
vis.events.subscribe(vis.events.FILE_SAVE_PRE, fmt_file)

local function build_files(win)
	local build_tex = function (f)
		local cmd = "pdflatex -halt-on-error " .. f.name

		-- build pdf
		local err, ostr = vis:pipe(f, {start = 0, finish = 0}, cmd)
		if err ~= 0 then
			if ostr then vis:message(ostr) end
			return false
		end

		local fp = util:splitext(f.name)
		-- update refrences
		vis:command("!biber " .. fp .. " >/dev/null")
		-- update glossary
		-- vis:command("!makeglossaries " .. fp .. " >/dev/null")

		-- build pdf with updated references
		err = vis:pipe(f, {start = 0, finish = 0}, cmd)
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

	win:map(vis.modes.NORMAL, ",c", function ()
			vis:command('w')
			vis:info("building: " .. win.file.name)
			return builder(win.file)
		end, "build file in current window")
end
vis.events.subscribe(vis.events.WIN_OPEN, build_files)
vis:command_register("build", function()
		vis:feedkeys(",c")
	end, "build file in current window")
