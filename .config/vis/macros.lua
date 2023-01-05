require('util')

local function macros(win)
	local lang = {}
	lang['.tex'] = {
		{ 'normal', '\\bf', 'i\\\\textbf{}<Escape>hi' },
		{ 'normal', '\\ca', 'i\\begin{cases}<Enter>\\end{cases}<Escape>O' },
		{ 'normal', '\\do', 'i\\begin{document}<Enter><Enter><Enter>\\end{document}<Escape>kO\\item' },
		{ 'normal', '\\en', 'i\\begin{enumerate}<Enter><Enter><Enter>\\end{enumerate}<Escape>kO\\item' },
		{ 'normal', '\\eq', 'i\\begin{equation}<Enter>\\end{equation}<Escape>O' },
		{ 'normal', '\\it', 'i\\begin{itemize}<Enter><Enter><Enter>\\end{itemize}<Escape>kO\\item' },
		{ 'normal', '\\se', 'i\\section{}<Escape>hi' },
		{ 'normal', '\\su', 'i\\subsection{}<Escape>hi' },
	}
	lang['.hs'] = {
		{ 'normal', 'gq', 'vip:|hindent<Enter><Escape>'},
	}

	local _, e = util:splitext(win.file.name)

	local binds = lang[e]
	if binds == nil then return end

	for _, map in pairs(binds) do
		vis:command(string.format('map! %s %s %s', map[1], map[2], map[3]))
	end
end
vis.events.subscribe(vis.events.WIN_OPEN, macros)
