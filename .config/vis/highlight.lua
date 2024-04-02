local M = {}

local lpeg_pattern
local get_keywords = function(range_or_text)
	local keywords = M.keywords
	if not keywords or #keywords == 0 then return end

	if not lpeg_pattern then
		local lpeg = vis.lpeg
		local words = lpeg.P(keywords[1])
		for i = 2, #keywords, 1 do
			words = words + lpeg.P(keywords[i])
		end
		local cap = (1 - words)^0 * (lpeg.Cp() * words * lpeg.Cp())
		lpeg_pattern = lpeg.Ct(cap * ((1 - words) * cap)^0)
	end

	local txt
	if type(range_or_text) == 'string' then
		txt = range_or_text
	else
		txt = vis.win.file:content(range_or_text)
	end

	local kws = lpeg_pattern:match(txt)
	if not kws then return end

	local kwt = {}
	local i = 1
	repeat
		table.insert(kwt, {kws[i], kws[i + 1] - 1})
		i = i + 2
	until (i > #kws)
	return kwt
end

local last_data
local last_modified_toks
local wrap_lexer = function()
	if not vis.win.syntax or not vis.lexers.load then return end

	local vlexer = vis.lexers.load(vis.win.syntax, nil, true)
	if not vlexer or not vlexer.lex then return end
	local old_lex_func = vlexer.lex

	vlexer.lex = function(lexer, data, index)
		local tokens = old_lex_func(lexer, data, index)
		local new_tokens = {}
		local kwt
		if last_data ~= data then
			kwt = get_keywords(data)
			if not kwt then return tokens end
			last_data = data
		else
			return last_modified_toks
		end

		local i = 1
		for _, kwp in ipairs(kwt) do repeat
			if i > #tokens - 1 then break end
			local token_type = tokens[i]
			local token_start = (tokens[i - 1] or 1) - 1
			local token_end = tokens[i + 1]
			local kws = kwp[1]
			local kwe = kwp[2]

			if token_end < kws then
				table.insert(new_tokens, token_type)
				table.insert(new_tokens, token_end)
				i = i + 2
			else
				-- if kw is within token we need to split
				-- the initial part of token off
				if kws - 1 > token_start then
					table.insert(new_tokens, token_type)
					table.insert(new_tokens, kws)
				end
				-- insert kw as error token
				table.insert(new_tokens, vis.lexers.ERROR)
				if token_end < kwe then
					table.insert(new_tokens, token_end + 1)
					i = i + 2
				else
					table.insert(new_tokens, kwe + 1)
				end
			end
		until (not token_end or token_end >= kwe) end
		-- copy over remaining tokens
		for j = i, #tokens, 1 do
			table.insert(new_tokens, tokens[j])
		end
		last_modified_toks = new_tokens
		return new_tokens
	end
end

vis.events.subscribe(vis.events.WIN_OPEN, function() wrap_lexer() end)

return M
