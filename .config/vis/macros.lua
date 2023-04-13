-- function chain
local function fc(argv)
	return function ()
		for _, f in ipairs(argv) do f() end
		return true
	end
end

-- insert
local function ins(str)
	return function ()
		local win = vis.win
		local pos = win.selection.pos
		win.file:insert(pos, str)
		win.selection.pos = pos + #str
		return true
	end
end

-- surround selection
local function sur(p, s)
	return function ()
		local win = vis.win
		for sel in win:selections_iterator() do
			win.file:insert(sel.range.start, p)
			win.file:insert(sel.range.finish, s)
		end
		win:draw()
		return true
	end
end

-- feedkeys
local function fk(fkeys)
	return function ()
		vis:feedkeys(fkeys)
		return true
	end
end

local function macros(win)
	local m = vis.modes
	local lang = {}
	lang["latex"] = {
		{ m.NORMAL, "\\al", fc({ ins("\\begin{align*}\n\\end{align*}"), fk("O") }) },
		{ m.NORMAL, "\\ca", fc({ ins("\\begin{cases}\n\\end{cases}"), fk("O") }) },
		{ m.NORMAL, "\\cb", fc({ ins("\\begin{center}\n\\colorboxed{blue}{\n}\n\\end{center}"), fk("kO") }) },
		{ m.NORMAL, "\\en", fc({ ins("\\begin{enumerate}\n\n\\item \n\n\\end{enumerate}"), fk("kkA") }) },
		{ m.NORMAL, "\\eq", fc({ ins("\\begin{equation*}\n\\end{equation*}"), fk("O") }) },
		{ m.NORMAL, "\\fi", fc({ ins("\\begin{figure}\n\\includegraphics[width=\\textwidth]{}\n\\end{figure}"), fk("k$hi") }) },
		{ m.NORMAL, "\\it", fc({ ins("\\begin{itemize}\n\n\\item \n\n\\end{itemize}"), fk("kkA") }) },
		{ m.NORMAL, "\\ne", fc({ ins("\\begin{equation}\n\\end{equation}"), fk("O") }) },
		{ m.NORMAL, "\\se", fc({ ins("\\section{}"), fk("hi") }) },
		{ m.NORMAL, "\\su", fc({ ins("\\subsection{}"), fk("hi") }) },
		{ m.VISUAL, "\\bf", sur("\\textbf{", "}") },
		{ m.VISUAL, "\\cb", sur("\\colorboxed{blue}{\n", "}\n") },
		{ m.VISUAL, "\\ce", sur("\\begin{center}\n", "\\end{center}\n") },
		{ m.VISUAL, "\\em", sur("\\emph{", "}") },
		{ m.VISUAL, "\\hl", sur("\\hl{", "}") },
	}
	lang["haskell"] = {
		{ m.NORMAL, "gq", fk("vip:|hindent<Enter><Escape>") },
	}

	local binds = lang[win.syntax]
	if binds == nil then return end

	for _, map in pairs(binds) do
		win:map(map[1], map[2], map[3])
	end
end
vis.events.subscribe(vis.events.WIN_OPEN, macros)
