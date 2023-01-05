require('util')

gpg = { key = 0 }

local function decrypt(file)
	local f, e = util:splitext(file.name)
	if e ~= '.gpg' then return end

	local err, ostr, estr = vis:pipe(file, {start = 0, finish = file.size}, "gpg -d")
	if err ~= 0 then return false end

	local i = estr:find("ID")
	local j = estr:find(",", i)
	local keyid = estr:sub(i+3, j-1)
	if keyid ~= gpg.key then
		vis:info(estr:gsub("\n[ ]*", " "))
		gpg.key = keyid
	end

	file:delete(0, file.size)
	file:insert(0, ostr)
	file.modified = false
	return true
end
vis.events.subscribe(vis.events.FILE_OPEN, decrypt)
vis.events.subscribe(vis.events.FILE_SAVE_POST, decrypt)

local function encrypt(file, path)
	local f, e = util:splitext(file.name)
	if e ~= '.gpg' then return end

	if gpg.key == 0 then
		vis:info('encrypt: keyid not found. file not saved.')
		return false
	end

	local tfn = os.tmpname()
	local cmd = "gpg --yes -o " .. tfn .. " -e -r " .. gpg.key
	local err, ostr, estr = vis:pipe(file, {start = 0, finish = file.size}, cmd)
	if err ~= 0 then
		if estr then
			vis:message(estr)
		end
		return false
	end

	local tf = io.open(tfn, 'rb')
	file:delete(0, file.size)
	file:insert(0, tf:read("a"))
	tf:close()
	os.remove(tfn)

	return true
end
vis.events.subscribe(vis.events.FILE_SAVE_PRE, encrypt)
