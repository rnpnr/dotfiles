local util = require('util')

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
local function sur(pre, suf, trim)
	return function ()
		local win = vis.win
		if trim then vis:feedkeys("_") end
		for sel in win:selections_iterator() do
			win.file:insert(sel.range.start, pre)
			win.file:insert(sel.range.finish, suf)
		end
		win:draw()
		return true
	end
end

-- inserts a latex environment
local lenv = function(env, inner)
	local out = "\\begin{%s}\n%s\\end{%s}"
	if (inner) then inner = inner .. "\n" end
	return ins(out:format(env, (inner or ""), env))
end

local function macros(win)
	local m = vis.modes
	local fc, fk = util.function_chain, util.feedkeys

	local lang = {}
	lang["latex"] = {
		{ m.NORMAL, "\\al", fc({ lenv("align*"), fk("O\t") }) },
		{ m.NORMAL, "\\ca", fc({ lenv("cases"), fk("O\t") }) },
		{ m.NORMAL, "\\cb", fc({ lenv("center", "\\colorboxed{blue}{\n}"), fk("kO\t") }) },
		{ m.NORMAL, "\\en", fc({ lenv("enumerate","\n\\item \n"), fk("kkA") }) },
		{ m.NORMAL, "\\eq", fc({ lenv("equation*"), fk("O\t") }) },
		{ m.NORMAL, "\\fi", fc({ lenv("figure", "\t\\includegraphics[width=\\textwidth]{}"), fk("k$hi") }) },
		{ m.NORMAL, "\\it", fc({ lenv("itemize", "\n\\item \n"), fk("kkA") }) },
		{ m.NORMAL, "\\mi", fc({ ins("\\begin{minipage}[c]{0.49\\textwidth}\n\\end{minipage}\\hfill"), fk("O\t") }) },
		{ m.NORMAL, "\\ne", fc({ lenv("equation"), fk("O\t") }) },
		{ m.NORMAL, "\\se", fc({ ins("\\section{}"), fk("hi") }) },
		{ m.NORMAL, "\\su", fc({ ins("\\subsection{}"), fk("hi") }) },
		{ m.VISUAL, "\\bf", sur("\\textbf{", "}", true) },
		{ m.VISUAL, "\\cb", sur("\\colorboxed{blue}{\n", "}\n") },
		{ m.VISUAL, "\\ce", sur("\\begin{center}\n", "\\end{center}\n") },
		{ m.VISUAL, "\\em", sur("\\emph{", "}", true) },
		{ m.VISUAL, "\\hl", sur("\\hl{", "}", true) },
		{ m.VISUAL, "\\mi", sur("\\begin{minipage}[c]{0.49\\textwidth}\n", "\\end{minipage}\\hfill\n") },
	}
	lang["haskell"] = {
		{ m.NORMAL, "gq", "vip:|hindent<Enter><Escape>" },
	}

	local binds = lang[win.syntax]
	if binds == nil then return end

	for _, map in pairs(binds) do
		win:map(map[1], map[2], map[3])
	end
end
vis.events.subscribe(vis.events.WIN_OPEN, macros)
