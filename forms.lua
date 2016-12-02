--Forms by Microeinstein

loadfile("std")()

running = false

Bounds = {}
Item = {}
Panel = {}
TextBox = {}
Label = {}
Button = {}
Image = {}

mainPanel = nil
focused = nil

types = {
	panel	= 0,
	label	= 1,
	button	= 2,
	textBox = 3,
	image	= 4
}
align = {
	topLeft		= 0,
	center		= 1,
	bottomRight = 2
}
resolutions = {
	computer = { w = 51, h = 19 },
	turtle = { w = 39, h = 13 },
	poket = { w = 26, h = 20 }
}
events = {
	click	 = 0,
	drag	 = 1,
	scroll	 = 2,
	key		 = 3,
	text	 = 4,
	focusOn	 = 5,
	focusOff = 6
}

--Other
function grid(initX, initY, columns, rows, offX, offY)
	local m = {}
	offX = offX or {0}
	offY = offY or {0}
	local ix, iy = 1, 1
	for col = 1, columns do
		m[col] = {}
		iy = 1
		for row = 1, rows do
			m[col][row] = {
				x = initX + offX[ix] + (col - 1),
				y = initY + offX[iy] + (row - 1)
			}
			iy = table.cycle(offY, iy)
		end
		ix = table.cycle(offX, ix)
	end
	return m
end
function typeName(t)
	local pT = "generic item"
	if t then
		if	   t == 0 then pT = "panel"
		elseif t == 1 then pT = "label"
		elseif t == 2 then pT = "button"
		elseif t == 3 then pT = "textBox"
		end 
	end
	return pT
end

--Bounds
function Bounds.x1(self)
	local r = self.bind.x
	if self.bind.parent then
		r = self.bind.parent.bounds:x1() + r
	end
	return r
end
function Bounds.y1(self)
	local r = self.bind.y
	if self.bind.parent then
		r = self.bind.parent.bounds:y1() + r
	end
	return r
end
function Bounds.x2(self)
	local r = self:x1() + self.bind.width - 1
	if self.bind.parent then
		r = math.min(self.bind.parent.bounds:x2(), r)
	end
	return r
end
function Bounds.y2(self)
	local r = self:y1() + self.bind.height - 1
	if self.bind.parent then
		r = math.min(self.bind.parent.bounds:y2(), r)
	end
	return r
end
function Bounds.rect(self)
	return self:x1(), self:y1(), self:x2(), self:y2()
end
function Bounds.inside(self, x, y)
	return (x >= self:x1() and x <= self:x2()) and (y >= self:y1() and y <= self:y2())
end

--Item
function Item.foreground(self)
	--if focused and focused == self and self._type == types.textBox then
	--	return colors.black
	--else
	if self._foreground then
		return self._foreground
	elseif self.parent then
		return self.parent:foreground()
	else
		return colors.white
	end
end
function Item.background(self)
	--if focused and focused == self and self._type == types.textBox then
	--	return colors.white
	--else
	if self._background then
		return self._background
	elseif self.parent then
		return self.parent:background()
	else
		return colors.black
	end
end
function Item.isEnabled(self)
	if not self.parent then
		return self._enable
	else
		return self._enable and self.parent:isEnabled()
	end
end
function Item.isInverted(self)
	if not self.parent then
		return self._inverted
	else
		return self._inverted ~= self.parent:isInverted()
	end
end
function Item.txtFix(self)
	self.tLines = self.tLines or {}
	local r = true
	for l, txt in pairs(self.tLines) do
		if string.contains(txt, "\n") then
			r = true
			for i, part in pairs(string.split(txt, "\n")) do
				if r then
					self.tLines[l] = part
					r = false
				else
					table.insert(self.tLines, l + i - 1, part)
				end
			end
		end
	end
end
--[[function Item.txtLX(self)
	local m = -1
	for i, l in pairs(self.tLines) do
		if m == -1 then
			m = #l
		else
			m = math.max(m, #l)
		end
	end
	return m
end
function Item.txtLY(self)
	return #self.tLines
end]]
function Item.txtX(self, text)
	local r = 0
	if self._type == types.textBox then
		self.alignX = align.topLeft
	end
	if not self.alignX or self.alignX == align.center then
		r = math.center(self.bounds:x1(), self.bounds:x2(), #text - 0.5)
	elseif self.alignX == align.topLeft then
		r = self.bounds:x1()
	elseif self.alignX == align.bottomRight then
		r = self.bounds:x2() - #text + 1
	end
	return r
end
function Item.txtY(self, lineNumber)
	local r = 0
	if self._type == types.textBox and self.multiLine then
		self.alignY = align.topLeft
	end
	if not self.alignY or self.alignY == align.center then
		r = math.center(self.bounds:y1(), self.bounds:y2(), #self.tLines - 1)
	elseif self.alignY == align.topLeft then
		r = self.bounds:y1()
	elseif self.alignY == align.bottomRight then
		r = self.bounds:y2() - #self.tLines + 1
	end
	return r + lineNumber - 1
end
function Item.paint(self)
	if self.visible then
		--Values
		local x1, y1, x2, y2 = self.bounds:rect()
		local oldX, oldY = term.getCursorPos()
		local fg, bg = self:foreground(), self:background()
		if self:isInverted() then
			local tbg = bg
			bg = fg
			fg = tbg
		end
		
		--Paint background and borders
		if term.isColor() then
			paintutils.drawFilledBox(x1, y1, x2, y2, bg)
			if self.image then
				paintutils.drawImage(self.image, x1, y1)
			end
			if self.border then
				paintutils.drawBox(x1 - 1, y1 - 1, x2 + 1, y2 + 1, self.border)
			end
		end
		
		if self.tLines and #self.tLines > 0 then
			--Write text
			local vX, vY = self._vX or 0, self._vY or 0
			if term.isColor() then
				term.setTextColor(fg)
				term.setBackgroundColor(bg)
			end
			
			for i, l in pairs(self.tLines) do
				local txtX, txtY = self:txtX(l), self:txtY(i) - vY
				if txtY >= y1 and txtY <= y2 then
					term.setCursorPos(txtX, txtY)
					term.write(l:sub(vX + 1, vX + self.width))
				end
				--term.log(true, self.x, self.y, "-", x1, y1, "-", txtX, txtY)
			end
		end
		
		term.setCursorPos(oldX, oldY)
		
		if self.items then
			for id, it in pairs(table.reverse(self.items, true)) do
				it:paint()
			end
		end
	end
end
function Item.setText(self, text)
	if type(text) == "table" then
		self.tLines = {}
		for i, l in pairs(text) do
			table.insert(self.tLines, l)
		end
	else
		self.tLines = {(text or "") .. ""}
	end
	self:txtFix()
	if self._type == types.textBox then
		self:caretMove()
	end
	self:paint()
end
function Item.getText(self)
	local txt = ""
	if self.tLines then
		local l = #self.tLines
		for i = 1, l do
			txt = txt .. self.tLines[i]
			if i < l then
				txt = txt .. "\n"
			end
		end
	end
	return txt
end
function Item._click(self, mB, x, y, diffx, diffy)
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	--Internal
	if self._type == types.panel then
		for n, i in pairs(self.items) do
			if i.bounds:inside(x, y) then
				i:_click(mButton, x, y, diffx, diffy)
				return
			end
		end
	elseif self._type == types.button then
		self._inverted = true
		self:paint()
		os.sleep(0.1)
		self._inverted = false
		self:paint()
	elseif self._type == types.textBox then
		self:caretMove(diffx, diffy, true)
	end
	if focused ~= nil and focused ~= self then
		focused:_focusOff()
	end
	self:_focusOn()
	--External
	if self:isEnabled() and self.eClick then
		for k, e in pairs(self.eClick) do
			e(self, mB, diffx, diffy)
		end
	end
end
function Item._drag(self, mB, x, y, diffx, diffy)
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	--Internal
	--External
	if self:isEnabled() and self.eDrag then
		for k, e in pairs(self.eDrag) do
			e(self, mB, diffx, diffy)
		end
	end
end
function Item._scroll(self, dir, x, y, diffx, diffy)
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	--Internal
	if self._type == types.textBox then
		self._vY = self._vY + dir
		self:caretMove()
	end
	
	--External
	if self:isEnabled() and self.eScroll then
		for k, e in pairs(self.eScroll) do
			e(self, dir, diffx, diffy)
		end
	end
end
function Item._key(self, key, pressing)
	--Internal
	if self._type == types.textBox then
		self:handleKey(key, pressing)
	end
	--External
	if self.eKey then
		for k, e in pairs(self.eKey) do
			e(self, key, pressing)
		end
	end
end
function Item._text(self, text)
	--Internal
	if self._type == types.textBox then
		self:addText(text)
	end
	--External
	if self.eText then
		for k, e in pairs(self.eText) do
			e(self, key)
		end
	end
end
function Item._focusOn(self)
	if self:isEnabled() then
		--Internal
		focused = self
		if self._type == types.textBox then
			self._inverted = true
			self:paint()
			term.setCursorBlink(true)
			self:caretUpdate()
		end
		--External
		if self.eFocusOn then
			for k, e in pairs(self.eFocusOn) do
				e(self)
			end
		end
	end
end
function Item._focusOff(self)
	--Internal
	focused = nil
	if self._type == types.textBox then
		self._inverted = false
		term.setCursorBlink(false)
		self:paint()
	end
	--External
	if self.eFocusOff then
		for k, e in pairs(self.eFocusOff) do
			e(self)
		end
	end
end
function Item.uniEvent(self)
	self.eClick		= self.eClick or {}
	self.eDrag		= self.eDrag or {}
	self.eScroll	= self.eScroll or {}
	self.eKey		= self.eKey or {}
	self.eText		= self.eText or {}
	self.eFocusOn	= self.eFocusOn or {}
	self.eFocusOff	= self.eFocusOff or {}
end
function Item.remEvent(self, eType, event)
	self:uniEvent()
	if eType ~= nil and event ~= nil then
		if		eType == events.click		then table.remove(self.eClick, event)
		elseif	eType == events.drag		then table.remove(self.eDrag, event)
		elseif	eType == events.scroll		then table.remove(self.eScroll, event)
		elseif	eType == events.key			then table.remove(self.eKey, event)
		elseif	eType == events.text		then table.remove(self.eText, event)
		elseif	eType == events.focusOn		then table.remove(self.eFocusOn, event)
		elseif	eType == events.focusOff	then table.remove(self.eFocusOff, event)
		end
	end
end
function Item.addEvent(self, eType, event)
	self:uniEvent()
	if eType ~= nil and event ~= nil then
		if		eType == events.click		then table.insert(self.eClick, event)
		elseif	eType == events.drag		then table.insert(self.eDrag, event)
		elseif	eType == events.scroll		then table.insert(self.eScroll, event)
		elseif	eType == events.key			then table.insert(self.eKey, event)
		elseif	eType == events.text		then table.insert(self.eText, event)
		elseif	eType == events.focusOn		then table.insert(self.eFocusOn, event)
		elseif	eType == events.focusOff	then table.insert(self.eFocusOff, event)
		end
	end
end

--Panel
function Panel.addItem(self, it, name)
	local can = (it ~= nil)
	if can then
		if it.parent == nil or it.parent ~= self then
			it.parent = self
		end
		if not self.items then
			self.items = {}
		end
		it.name = name
		table.insert(self.items, it)
		refresh()
	end
	return can
end
function Panel.addItems(self, items)
	for k, i in pairs(items) do
		self:addItem(i, k)
	end
end
function Panel.remItem(self, name)
	local is = self.items and self.items[name]
	if is then
		table.remove(self.items, name)
		refresh()
	end
	return is
end

--TextBox
function TextBox.caretPos(self)
	return (self._cX - self._vX), (self._cY - self._vY)
end
function TextBox.caretFinal(self)
	local cx, cy = self:caretPos()
	return self.bounds:x1() + cx, self.bounds:y1() + cy
end
function TextBox.caretUpdate(self)
	local fX, fY = self:caretFinal()
	local ok = (focused ~= nil
			and focused == self
			and self:isEnabled()
			and (self.width < 3 or self.bounds:inside(fX, fY)))
	term.setCursorBlink(ok)
	term.setCursorPos(fX, fY)
end
function TextBox.caretMove(self, diffX, diffY, fixed, uncheck)
	diffX = diffX or 0
	diffY = diffY or 0
	local lns = #self.tLines
	
	--Move caret position
	if not fixed then
		if not uncheck then
			self._cX = self._cX + diffX
			if self._cX > #(self:line()) then
				if self._cY < lns - 1 then
					self._cX = self._cX - #(self:line()) - 1
					self._cY = self._cY + 1
				else
					self._cX = #(self:line())
				end
			elseif self._cX < 0 then
				if self._cY > 0 then
					self._cX = #(self:line(-1)) + self._cX + 1
					self._cY = self._cY - 1
				else
					self._cX = 0
				end
			end
			self._cY = math.between(0, self._cY + diffY, lns - 1)
			self._cX = math.between(0, self._cX, #(self:line()))
		else
			self._cY = math.between(0, self._cY + diffY, lns - 1)
			self._cX = math.between(0, self._cX + diffX, #(self:line()))
		end
	else
		self._cY = math.between(0, self._vY + diffY, lns - 1)
		self._cX = math.between(0, self._vX + diffX, #(self:line()))
	end
	
	--Move viewing position
	local cX, cY = self:caretPos()
	local fX, fY = self:caretFinal()
	local x1, y1, x2, y2 = self.bounds:rect()
	
	if diffX ~= 0 then
		if fX < x1 then
			self._vX = self._vX - (x1 - fX)
		elseif fX > x2 then
			self._vX = self._vX + (fX - x2)
		--elseif self._cX >= self.width - 1 and self._vX + self.width - 1 > table.len(self:line()) then
		--	self._vX = math.max(0, self._vX - 1)
		end
	end
	if diffY ~= 0 then
		if fY < y1 then
			self._vY = self._vY - (y1 - fY)
		elseif fY > y2 then
			self._vY = self._vY + (fY - y2)
		--elseif self._cY >= self.height - 2 and self._vY + self.height > lns then
		--	self._vY = math.max(0, self._vY - 1)
		end
	end
	self._vX = math.between(0, self._vX, #(self:line()) - self.width + (self.width > 2 and 1 or 0))
	self._vY = math.between(0, self._vY, lns - self.height)
	
	--term.log(false, self._vX, self._vY, self._cX, self._cY)
	
	self:paint()
	self:caretUpdate()
end
function TextBox.addText(self, text)
	--LONG\nTEXT\nOVER\nMULTIPLE\nLINES
	--Becouse CC doesn't allow multiline paste
	text = string.replace(text, "\\n", "\n")
	local chrz = string.chars(text)
	for i, c in pairs(chrz) do
		if c == "\n" then
			self:newLine()
		else
			local p1, p2 = string.split(self:line(0), self._cX)
			self:line(0, p1 .. c .. p2)
			self:caretMove(1)
		end
	end
	self:txtFix()
	self:caretMove()
end
function TextBox.handleKey(self, key, pressing)
	if key == keys.backspace then
		if self._cX > 0 then
			local p1, p2 = string.split(self:line(), self._cX)
			self:line(0, p1:sub(1, #p1 - 1) .. p2)
			self:caretMove(-1)
		elseif self._cY > 0 then
			local l1, l2 = self:line(-1), self:line()
			self:line(-1, l1 .. l2)
			table.remove(self.tLines, self._cY + 1)
			self:caretMove(-#l2 - 1)
		end
		
	elseif key == keys.enter then
		self:newLine()
		
	elseif key == keys.delete then
		if self._cX < #(self:line()) then
			local p1, p2 = string.split(self:line(), self._cX)
			self:line(0, p1 .. p2:sub(2, #p2))
			self:caretMove()
		elseif self._cY < #self.tLines then
			local l1, l2 = self:line(), self:line(1)
			self:line(0, l1 .. l2)
			table.remove(self.tLines, self._cY + 2)
			self:caretMove()
		end
		
	elseif key == keys.home then
		self:caretMove(-self._cX)
		
	elseif key == keys["end"] then
		self:caretMove(#(self:line()) - self._cX)
		
	elseif key == keys.pageUp then
		self:caretMove(0, -self.height)
		
	elseif key == keys.pageDown then
		self:caretMove(0, self.height)
		
	elseif key == keys.up then
		self:caretMove(0, -1)
		
	elseif key == keys.down then
		self:caretMove(0, 1)
		
	elseif key == keys.left then
		self:caretMove(-1)
		
	elseif key == keys.right then
		self:caretMove(1)
		
	elseif key == keys.leftAlt then
		if self._cY > 0 then
			local l, lp = self:line(), self:line(-1)
			self:line(-1, l)
			self:line(0, lp)
			self:caretMove(0, -1, false, true)
		end
		
	elseif key == keys.rightAlt then
		if self._cY < #self.tLines - 1 then
			local l, ln = self:line(), self:line(1)
			self:line(1, l)
			self:line(0, ln)
			self:caretMove(0, 1, false, true)
		end
	
	end
end
function TextBox.newLine(self)
	if self.multiLine then
		local p1, p2 = string.split(self:line(), self._cX)
		self:line(0, p1)
		table.insert(self.tLines, self._cY + 2, p2)
		self:caretMove(-#p1, 1)
	end
end
function TextBox.line(self, delta, new)
	delta = delta or 0
	if new then
		self.tLines[self._cY + 1 + delta] = new
		return new
	else
		local l = self.tLines[self._cY + 1 + delta]
		if l then
			return l
		else
			return ""
		end
	end
end

--Constructors
function Bounds.new(item)
	local b = {}
	b.x1 = Bounds.x1
	b.y1 = Bounds.y1
	b.x2 = Bounds.x2
	b.y2 = Bounds.y2
	b.rect = Bounds.rect
	b.inside = Bounds.inside
	b.bind = item or {}
	return b
end
function Item.new(x, y, text, w, h, fg, bg, border, _type, enabled)
	--print("New ", typeName(_type))
	--os.sleep(0.025)
	
	local i = {}
	i.bounds = Bounds.new(i)
	i.foreground = Item.foreground
	i.background = Item.background
	i.isEnabled = Item.isEnabled
	i.isInverted = Item.isInverted
	i.txtFix = Item.txtFix
	--i.txtLX = Item.txtLX
	--i.txtLY = Item.txtLY
	i.txtX = Item.txtX
	i.txtY = Item.txtY
	i.paint = Item.paint
	i.getText = Item.getText
	i.setText = Item.setText
	
	i.x = x
	i.y = y
	i:setText(text)
	i.width = w or string.lenX((text or ""))
	i.height = h or (text and string.lenY(text)) or 1
	i._foreground = fg
	i._background = bg
	i.border = border
	i._enable = enabled or true
	i.visible = true
	i._inverted = false
	i._type = _type
	i.alignX = nil
	i.alignY = nil
	
	i._click = Item._click
	i._drag = Item._drag
	i._scroll = Item._scroll
	i._key = Item._key
	i._text = Item._text
	i._focusOn = Item._focusOn
	i._focusOff = Item._focusOff
	i.uniEvent = Item.uniEvent
	i.addEvent = Item.addEvent
	i.remEvent = Item.remEvent
	i.eClick = {}
	i.eDrag = {}
	i.eScroll = {}
	i.eKey = {}
	i.eText = {}
	i.eFocusOn = {}
	i.eFocusOff = {}
	
	return i
end
function Panel.new(x, y, w, h, fg, bg, border)
	local p = Item.new(x, y, nil, w, h, fg, bg, border, types.panel)
	p.items = {}
	p.addItem = Panel.addItem
	p.addItems = Panel.addItems
	p.remItem = Panel.remItem
	return p
end
function TextBox.new(x, y, text, w, h, fg, bg, multi)
	local t = Item.new(x, y, text, w, h, fg, bg, nil, types.textBox)
	t._vX = 0
	t._vY = 0
	t._cX = 0
	t._cY = 0
	t.multiLine = multi or string.contains(text, "\n")
	
	t.viewPosX = TextBox.viewPosX
	t.viewPosY = TextBox.viewPosY
	t.caretPos = TextBox.caretPos
	t.caretFinal = TextBox.caretFinal
	t.caretUpdate = TextBox.caretUpdate
	t.caretMove = TextBox.caretMove
	t.addText = TextBox.addText
	t.handleKey = TextBox.handleKey
	t.newLine = TextBox.newLine
	t.line = TextBox.line
	return t
end
function Label.new(x, y, text, w, h, fg, bg)
	local l = Item.new(x, y, text, w, h, fg, bg, nil, types.label)
	return l
end
function Button.new(x, y, text, w, h, fg, bg, eClick)
	local b = Item.new(x, y, text, w, h, fg, bg, nil, types.button)
	b:addEvent(events.click, eClick)
	return b
end
function Image.new(x, y, image)
	local w, h = 0, 0
	if image ~= nil then
		for n, r in pairs(image) do
			w = w + 1
			local lh = 0
			for p, c in pairs(r) do
				lh = lh + 1
			end
			h = math.max(h, lh)
		end
	end
	
	local i = Item.new(x, y, nil, w, h, nil, nil, nil, types.image)
	i.image = image
	return i
end

--Form
function init(fg, bg)
	print("Form Init")
	local w, h = term.getSize()
	mainPanel = Panel.new(1, 1, w, h, fg or colors.white, bg or colors.black)
end
function click(mButton, x, y)
	mainPanel:_click(mButton, x, y)
end
function refresh()
	if running then
		term.clear()
		mainPanel:paint()
	end
end
function run()
	running = true
	term.setCursorPos(1, 1)
	term.setCursorBlink(false)
	refresh()
	while true do
		local event, p1, p2, p3, p4, p5 = os.pullEvent()
		if event == "mouse_click" or event == "monitor_touch" then
			--mButton, x, y
			click(p1, p2, p3)
		elseif event == "mouse_drag" then
			--mButton, x, y
			if focused then
				focused:_drag(p1, p2, p3)
			end
		elseif event == "mouse_scroll" then
			-- +1 Down / -1 Up, x, y1
			if focused then
				focused:_scroll(p1, p2, p3)
			end
		elseif event == "char" or event == "paste" then
			--p1 = letter / text
			if focused then
				focused:_text(p1)
			end
		elseif event == "key" then
			--keyNumber, pressing
			if focused then
				focused:_key(p1, p2)
			end
		elseif event == "term_resize" then
			if focused then
				focused:_focusOff()
			end
			mainPanel.width, mainPanel.height = term.getSize()
			term.wash()
			refresh()
			return
		elseif event == "forms_stop" then
			term.wash()
			return
		end
	end
end
function stop()
	os.queueEvent("forms_stop")
end
