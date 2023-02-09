require('util')

local function macros(win)
	local function fi(str, fkeys)
		return function ()
			local win = vis.win
			local pos = win.selection.pos
			win.file:insert(pos, str)
			win.selection.pos = pos + #str
			vis:feedkeys(fkeys)
			return true
		end
	end

	local m = vis.modes
	local lang = {}
	lang['.tex'] = {
		{ m.NORMAL, "\\al", fi("\\begin{align*}\n\\end{align*}", "O") },
		{ m.NORMAL, "\\bf", fi("\\textbf{}", "hi") },
		{ m.NORMAL, "\\ca", fi("\\begin{cases}\n\\end{cases}", "O") },
		{ m.NORMAL, "\\cb", fi("\\begin{center}\n\\colorboxed{blue}{\n}\n\\end{center}", "kO") },
		{ m.NORMAL, "\\en", fi("\\begin{enumerate}\n\n\\item \n\n\\end{enumerate}", "kkA") },
		{ m.NORMAL, "\\eq", fi("\\begin{equation}\n\\end{equation}", "O") },
		{ m.NORMAL, "\\it", fi("\\begin{itemize}\n\n\\item \n\n\\end{itemize}", "kkA") },
		{ m.NORMAL, "\\se", fi("\\section{}", "hi") },
		{ m.NORMAL, "\\su", fi("\\subsection{}", "hi") },
	}
	lang['.hs'] = {
		{ m.NORMAL, "gq", fi("", "vip:|hindent<Enter><Escape>") },
	}

	local _, e = util:splitext(win.file.name)

	local binds = lang[e]
	if binds == nil then return end

	for _, map in pairs(binds) do
		win:map(map[1], map[2], map[3])
	end
end
vis.events.subscribe(vis.events.WIN_OPEN, macros)
