local M = {
	style_ids = {}
}

local longest_keyword_length = 0
local lpeg_pattern
vis.events.subscribe(vis.events.INIT, function()
	local keywords = M.keywords
	for tag, style in pairs(keywords) do
		M.style_ids[tag] = vis.ui:style_push(style)
		if #tag > longest_keyword_length then
			longest_keyword_length = #tag
		end
	end

	local lpeg = vis.lpeg
	-- TODO: can't this be done better?
	local words
	for tag, _ in pairs(keywords) do
		if words then
			words = words + lpeg.P(tag)
		else
			words = lpeg.P(tag)
		end
	end
	if not words then return end
	local cap = (1 - words)^0 * (lpeg.Cp() * words * lpeg.Cp())
	lpeg_pattern = lpeg.Ct(cap * ((1 - words) * cap)^0)
end)

local get_keywords = function(data)
	local i, kwt, kws = 1, {}, lpeg_pattern:match(data)
	if kws then
		repeat
			local kw = data:sub(kws[i], kws[i + 1] - 1)
			table.insert(kwt, {kw, kws[i] - 1, kws[i + 1] - 2})
			i = i + 2
		until (i > #kws)
	end
	return kwt
end

local last_data, last_tokens
vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
	local viewport = win.viewport.bytes
	if not viewport then return end
	local horizon_max = longest_keyword_length
	local horizon     = viewport.start < horizon_max and viewport.start or horizon_max
	local lex_start   = viewport.start - horizon
	viewport.start    = lex_start

	local data   = win.file:content(viewport)
	local tokens = last_tokens
	if last_data ~= data then
		tokens      = get_keywords(data)
		last_tokens = tokens;
		last_data   = data
	end

	local style_ids = M.style_ids
	for _, matches in pairs(tokens) do
		local style_id = style_ids[matches[1]]
		if style_id then
			win:style(style_id, lex_start + matches[2], lex_start + matches[3])
		end
	end
end)

return M
