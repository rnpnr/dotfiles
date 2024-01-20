-- generates a status line useful when running mpv
-- headless from the terminal as a music player
-- updates once per second and pauses with player

local chapter_str = ""
mp.observe_property("chapter", "number", function(_, cn)
	if cn == nil then chapter_str = "" return end
	local c = "\n> [" .. cn + 1 .. "/"
	c = c .. mp.get_property_osd("chapters") .. "] "
	c = c .. mp.get_property_osd("chapter-metadata/by-key/title")
	chapter_str = c
end)

local status_line = function()
	local status = ""
	local append = function(s) status = status .. s end
	append("> " .. mp.get_property_osd("media-title"))
	append(chapter_str)
	append("\n> " .. mp.get_property_osd("time-pos"))
	append("/"  .. mp.get_property_osd("duration"))
	append(" (Cached: " .. mp.get_property_osd("demuxer-cache-duration"))
	append(")")
	mp.set_property("options/term-status-msg", status)
end

timer = mp.add_periodic_timer(1, status_line)

local pause = function(_, paused)
	if paused then
		timer:stop()
	else
		timer:resume()
	end
	mp.add_timeout(0.1, status_line)
end

mp.observe_property("pause", "bool", pause)
mp.register_event("seek", status_line)
