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
		{ m.NORMAL, "\\bf", fc({ ins("\\textbf{}"), fk("hi") }) },
		{ m.NORMAL, "\\ca", fc({ ins("\\begin{cases}\n\\end{cases}"), fk("O") }) },
		{ m.NORMAL, "\\cb", fc({ ins("\\begin{center}\n\\colorboxed{blue}{\n}\n\\end{center}"), fk("kO") }) },
		{ m.NORMAL, "\\en", fc({ ins("\\begin{enumerate}\n\n\\item \n\n\\end{enumerate}"), fk("kkA") }) },
		{ m.NORMAL, "\\eq", fc({ ins("\\begin{equation*}\n\\end{equation*}"), fk("O") }) },
		{ m.NORMAL, "\\it", fc({ ins("\\begin{itemize}\n\n\\item \n\n\\end{itemize}"), fk("kkA") }) },
		{ m.NORMAL, "\\se", fc({ ins("\\section{}"), fk("hi") }) },
		{ m.NORMAL, "\\su", fc({ ins("\\subsection{}"), fk("hi") }) },
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
