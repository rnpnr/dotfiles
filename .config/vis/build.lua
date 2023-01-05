require('util')

local function fmt(file, path)
	local win = vis.win
	local fmt = {}
	fmt["ansi_c"] = "clang-format -fallback-style=none"
	fmt["cpp"] = "clang-format -fallback-style=none"
	fmt["bibtex"] = "bibtidy"

	local cmd = fmt[win.syntax]
	if cmd == nil then return end

	local err, ostr, estr = vis:pipe(file, {start = 0, finish = file.size}, cmd)
	if err ~= 0 then
		if estr then
			vis:message(estr)
		end
		return false
	end

	local pos = win.selection.pos
	file:delete(0, file.size)
	file:insert(0, ostr)
	win.selection.pos = pos
	return true
end
vis.events.subscribe(vis.events.FILE_SAVE_PRE, fmt)

local function build_files(win)
	function error()
		vis:info('This filetype is not supported')
	end

	function build_tex(f)
		-- build pdf
		vis:command(string.format('!pdflatex -halt-on-error %s.tex >/dev/null', f))
		-- update refrences
		vis:command(string.format('!biber %s >/dev/null', f))
		-- update glossary
		-- vis:command(string.format('!makeglossaries %s >/dev/null', f))
		-- build pdf
		vis:command(string.format('!pdflatex -halt-on-error %s.tex >/dev/null', f))

		-- reload pdf (zathura does this automatically)
		-- vis:command('!pkill -HUP mupdf')
	end

	local lang = {}
	lang['.tex']    = build_tex

	function build()
		-- write file
		vis:command('w')

		local f, e = util:splitext(win.file.name)
		if f == nil then error() return end

		local method = lang[e]
		if method == nil then error() return end

		vis:info("building: " .. f .. e)
		method(f)
	end

	vis:map(vis.modes.NORMAL, ',c', build)
	vis:command_register('build', build)
end
vis.events.subscribe(vis.events.WIN_OPEN, build_files)
