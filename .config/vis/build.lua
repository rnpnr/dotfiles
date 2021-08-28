function build_files(win)
	function error()
		vis:info('This filetype is not supported')
	end

	function build_tex(f)
		-- build pdf
		vis:command(string.format('!lualatex %s >/dev/null', f))

		-- reload pdf (zathura does this automatically)
		-- vis:command('!pkill -HUP mupdf')
	end

	local lang = {}
	lang['.tex']    = build_tex

	function build()
		-- write file
		vis:command('w')

		local f = win.file.name
		if f == nil then error() return end

		local i = string.find(f, '%.')
		if i == nil then error() return end

		local method = lang[string.sub(f, i)]
		if method == nil then error() return end

		vis:info(string.format('building \'%s\'', f))
		method(f)
	end

	vis:map(vis.modes.NORMAL, ',c', build)
	vis:command_register('build', build)
end

vis.events.subscribe(vis.events.WIN_OPEN, build_files)
