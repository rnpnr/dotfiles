require('util')

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

		local f, e = splitext(win.file.name)
		if f == nil then error() return end

		local method = lang[e]
		if method == nil then error() return end

		vis:info(string.format('building: %s', f .. e))
		method(f)
	end

	vis:map(vis.modes.NORMAL, ',c', build)
	vis:command_register('build', build)
end
vis.events.subscribe(vis.events.WIN_OPEN, build_files)
