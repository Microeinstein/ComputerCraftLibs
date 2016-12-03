--STD addon by Microeinstein
--rPrint is not mine

function term.wash()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(1, 1)
end
function term.input(text, prefix)
	prefix = prefix or ""
	term.write(text..prefix)
	return prefix..io.read()
end
function term.lineBefore()
	local w, h = term.getSize()
	print(string.rep(" ", w))
	local x, y = term.getCursorPos()
	term.setCursorPos(x, y - 1)
end
function term.printc(fg, bg, ...)
	if term.isColor() then
		local fc, bc = term.getTextColor(), term.getBackgroundColor()
		term.setTextColor(fg or fc)
		term.setBackgroundColor(bg or bc)
		print(unpack(arg))
		term.setTextColor(fc)
		term.setBackgroundColor(bc)
	else
		print(unpack(arg))
	end
	term.lineBefore()
end
function term.log(pause, ...)
	if arg then
		local oldX, oldY = term.getCursorPos()
		local oldF, oldB = term.getTextColor(), term.getBackgroundColor()
		local sx, sy = term.getSize()
		
		paintutils.drawLine(1, sy, sx, sy, colors.black)
		term.setCursorPos(1, sy)
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
		
		term.write(table.concat(table.allToString(arg), " "))
		if pause then
			term.pause(nil, true)
		end
		
		term.setCursorPos(oldX, oldY)
		term.setTextColor(oldF)
		term.setBackgroundColor(oldB)
	end
end
function term.pause(text, useWrite)
	if not useWrite then
		print(tostring(text or "..."))
		term.lineBefore()
	else
		term.write(tostring(text or "..."))
	end
	while true do
		local event, p1, p2, p3, p4, p5 = os.pullEvent()
		if event == "key" then
			return
		end
	end
end

fs.mex = {
	okRead		= "File read",
	okWrite		= "File saved",
	genericErr	= "Unable to open file",
	notFound	= "File or directory not found",
	dirNotExp	= "This is a directory",
	fileNotExp	= "This is not a directory",
}
function fs.read(path)
	if not fs.exists(path) then
		return fs.mex.notFound
	end
	if fs.isDir(path) then
		return fs.mex.dirNotExp
	end
	
	local file = fs.open(path, "r")
	if not file then
		return fs.mex.genericErr
	end
	
	local cont = file.readAll();
	file.close()
	
	return fs.mex.okRead, cont
end
function fs.write(path, content)
	if fs.isDir(path) then
		return fs.mex.dirNotExp
	end
	
	local file = fs.open(path, "w")
	if not file then
		return fs.mex.genericErr
	end
	
	file.write(content)
	file.flush()
	file.close()
	
	return fs.mex.okWrite
end
function fs.readDir(path, recursive)
	if not fs.exists(path) then
		return fs.mex.notFound
	end
	if not fs.isDir(path) then
		return fs.mex.dirNotExp
	end
	
	local list = fs.list(path)
	local files = {}
	
	for _, f in pairs(list) do
		local p = fs.combine(path, f)
		if fs.isDir(p) then
			if recursive then
				local mex, obj = fs.readDir(p, recursive)
				if mex == fs.mex.okRead then
					for rp, rc in pairs(obj) do
						files[rp] = rc
					end
				end
			end
		else
			local mex, cont = fs.read(p)
			if mex == fs.mex.okRead then
				files[p] = cont
			else
				return mex, p
			end
		end
	end
	
	return fs.mex.okRead, files
end

function math.center(p1, p2, length)
	return math.floor((p1 + p2) / 2) - math.floor(length / 2)
end
function math.between(nMin, nV, nMax)
	return math.max(nMin, math.min(nV, nMax))
end
function math.numToXY(num, nMax)
	local tY = math.floor((num - 1) / nMax)
	return {
		x = num - (tY * nMax),
		y = tY + 1
	}
end
function math.xyToNum(x, y, nMax)
	return x + (y - 1) * nMax
end

function string.split(self, sep, esc)
	if type(sep) == "number" then
		if self then
			sep = math.between(0, sep, #self)
			return self:sub(1, sep), self:sub(sep + 1, #self)
		else
			return "", ""
		end
	elseif type(sep) == "string" then
		if self then
			local res = {}
			local escape = false
			local sepM, sepP, last = 0, 0, 1
			for i = 1, #self do
				local c = self:sub(i, i)
				sepP = sepM + 1
				if esc ~= nil and type(esc) == "string" and sepM == 0 and not escape and c == esc then
					escape = true
				elseif c == sep:sub(sepP, sepP) then
					sepM = sepP
					if sepM == #sep then
						if not escape then
							local s = self:sub(last, i - #sep)
							table.insert(res, s)
							last = i + 1
						end
						escape = false
						sepM = 0
					end
				else
					escape = false
					sepM = 0
				end
			end
			local s = self:sub(last, #self)
			table.insert(res, s)
			return res
		else
			return {}
		end
	end
end
function string.replace(self, strF, strR, esc)
	local res = {}
	local escape = false
	local sepM, sepP, ret = 0, 0, ""
	for i = 1, #self do
		local c = self:sub(i, i)
		sepP = sepM + 1
		if esc ~= nil and type(esc) == "string" and sepM == 0 and not escape and c == esc then
			escape = true
		elseif c == strF:sub(sepP, sepP) then
			sepM = sepP
			if sepM == #strF then
				if not escape then
					ret = ret .. strR
				else
					ret = ret .. self:sub(i - sepP, i)
				end
				escape = false
				sepM = 0
			end
		else
			ret = ret .. self:sub(i - sepM, i)
			escape = false
			sepM = 0
		end
	end
	return ret
end
function string.remChars(self, chrs, esc)
	for i, c in pairs(string.chars(chrs)) do
		self = string.replace(self, c, "", esc)
	end
	return self
end
function string.overwrite(self, str, from)
	from = (from or 0) + 1
	local slfC = string.chars(self)
	local strC = string.chars(str)
	local ret = ""
	local frmE = from + #strC
	for i = 1, #slfC do
		if i >= from and i < frmE then
			ret = ret .. strC[i - from + 1]
		else
			ret = ret .. slfC[i]
		end
	end
	return ret
end
function string.chars(self)
	local ch = {}
	for i = 1, #self do
		table.insert(ch, self:sub(i, i))
	end
	return ch
end
function string.contains(self, str)
	if self and str then
		local sepM, sepP = 0, 0
		for i = 1, #self do
			local c = self:sub(i, i)
			sepP = sepM + 1
			if c == str:sub(sepP, sepP) then
				sepM = sepP
				if sepM == #str then
					return true
				end
			else
				sepM = 0
			end
		end
		return false
	else
		return false
	end
end
function string.lenX(self)
	local m = -1
	for i, l in pairs(string.split(self, "\n")) do
		if m == -1 then
			m = #l
		else
			m = math.max(m, #l)
		end
	end
	return m
end
function string.lenY(self)
	return table.len(string.split(self, "\n"))
end
function string.isBlank(self)
	return self ~= nil and self:match("%S") ~= nil
end

function table.len(self, includeNil)
	includeNil = includeNil or false
	local c = 0
	for k, v in pairs(self) do
		if v or includeNil then
			c = c + 1
		end
	end
	return c
end
function table.copy(self, deep) --from http://lua-users.org/wiki/CopyTable shallow + deep
	deep = deep or false
	local orig_type = type(self)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(self) do
			if deep then
				copy[table.copy(orig_key, true)] = table.copy(orig_value, true)
			else
				copy[orig_key] = orig_value
			end
        end
		if deep then
			setmetatable(copy, table.copy(getmetatable(self)))
		end
    else
        copy = self
    end
    return copy
end
function table.reverse(self, noString)
	noString = noString or false
	local indexed, reversed = {}, {}
	local n = 0
	for k, v in pairs(self) do
		if noString or type(k) == "number" then
			n = n + 1
			indexed[n] = v
		else
			indexed[k] = v
		end
	end
	local l = #indexed
	for i, v in pairs(indexed) do
		if noString or type(i) == "number" then
			reversed[l - i + 1] = v
		else
			reversed[i] = v
		end
	end
	return reversed
end
function table.cycle(array, i, inc)
	if not array then return; end
	local l = #array
	
	if l < 1 then
		return
	elseif l == 1 then
		return 1
	else
		local r = (i or 0) + (inc or 1)
		if r > l then
			r = r - (l * math.floor(r / l))
		end
		return r
	end
end
function table.exist(self, lambda, ...)
	for k, v in pairs(self) do
		if lambda(k, v, unpack(arg)) then
			return true
		end
	end
	return false
end
function table.first(self, lambda, ...)
	for k, v in pairs(self) do
		if lambda(k, v, unpack(arg)) then
			return k, v
		end
	end
end
function table.last(self, lambda, ...)
	local a, b
	for k, v in pairs(self) do
		if lambda(k, v, unpack(arg)) then
			a, b = k, v
		end
	end
	return a, b
end
function table.where(self, lambda, ...)
	local ret = {}
	for k, v in pairs(self) do
		if lambda(k, v, unpack(arg)) then
			ret[k] = v
		end
	end
	return ret
end
function table.allToString(self)
	for k, v in pairs(self) do
		self[k] = tostring(v)
	end
	return self
end

function rPrint(s, l, i)		-- recursive Print (structure, limit, indent)
	l = l or 100;
	i = i or "";				-- default item limit, indent string
	os.sleep(0.1)
	
	if l < 1 then
		print("ERROR: Item limit reached.")
		return l-1
	end
	local ts = type(s)
	if ts ~= "table" then
		term.log(true, i, ts, tostring(s))
		return l - 1
	end
	term.log(true, i, ts)
	for k, v in pairs(s) do		-- print "[KEY] VALUE"
		if k ~= "parent" and k ~= "bind" and v ~= s then
			l = rPrint(v, l, i .. "." .. tostring(k))
			if l < 0 then
				break
			end
		end
	end
	return l
end
function objDebug(obj, prefix)
	rPrint(obj, nil, prefix)
	term.log(false, "OBJECT END")
	os.sleep(1)
end
