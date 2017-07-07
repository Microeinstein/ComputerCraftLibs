--Forms by Microeinstein

loadfile("std")()

__forms = {}

_running = false
_dragging = false
_texts = {
	words = {[[[%w_]+%s*]], [[[^%w_]+]]},
	dialogBtns = {"OK", "Cancel", "Yes", "No", "Retry", "Abort", "Ignore"}
}

Bounds = {}
Item = {}
Panel = {}
Label = {}
Button = {}
Image = {}
TextBox = {}
NumBox = {}
CheckBox = {}
Timer = {}
Dialog = {}
DragHandler = {}

mainPanel = nil
shownDialog = nil
_focused = nil
_runningTimers = {}
_keysTemp = {}

types = {
	panel		= 1,
	label		= 2,
	button		= 3,
	image		= 4,
	textBox		= 5,
	numBox	    = 6,
	checkBox	= 7
}
align = {
	topLeft		= 0,
	center		= 1,
	bottomRight	= 2
}
resolutions = {
	computer	= { w = 51, h = 19 },
	turtle		= { w = 39, h = 13 },
	poket		= { w = 26, h = 20 }
}
events = {
	click		= 1,
	mouseUp		= 2,
	drag		= 3,
	scroll		= 4,
	key			= 5,
	text		= 6,
	focusOn		= 7,
	focusOff	= 8,
	valueChange	= 9
}
keyEvents = {
	raw		= 0,
	up		= 1,
	press	= 2,
	hold	= 3
}
valueTypes = {
	text	= 1,
	number	= 2,
	checked	= 3
}
buttonStyles = {
	OK					= 1,
	OKCancel			= 2,
	YesNo				= 3,
	YesNoCancel			= 4,
	RetryCancel			= 5,
	AbortRetryIgnore	= 6
}
dialogResult = {
	OK		= 1,
	Cancel	= 2,
	Yes		= 3,
	No		= 4,
	Retry	= 5,
	Abort	= 6,
	Ignore	= 7
}
_styleResult = {
	{dialogResult.OK},
	{dialogResult.OK, dialogResult.Cancel},
	{dialogResult.Yes, dialogResult.No},
	{dialogResult.Yes, dialogResult.No, dialogResult.Cancel},
	{dialogResult.Retry, dialogResult.Cancel},
	{dialogResult.Abort, dialogResult.Retry, dialogResult.Ignore},
}

--Other
function makeGrid(columns, rows)
	local m = {}
	columns = columns or {0}
	rows = rows or {0}
	local ix, iy, sx, sy = 1, 1, 0, 0
	for col = 1, #columns do
		m[col] = {}
		iy = 1
		sy = 0
		sx = sx + columns[ix]
		for row = 1, #rows do
			sy = sy + rows[iy]
			m[col][row] = {
				x = sx + (col - 1),
				y = sy + (row - 1)
			}
			iy = iy + 1
		end
		ix = ix + 1
	end
	return m
end
function typeName(t)
	local pT = "generic item"
	if t then
		if	   t == 0 then pT = "panel"
		elseif t == 1 then pT = "label"
		elseif t == 2 then pT = "button"
		elseif t == 3 then pT = "image"
		elseif t == 4 then pT = "textBox"
		elseif t == 5 then pT = "numBox"
		elseif t == 6 then pT = "checkBox"
		end 
	end
	return pT
end
function keyIsDown(key)
	return _keysTemp[key] ~= nil
end
function _dragHandler(self, event, ...)
	if event == events.click then
		local mB, x, y, diffx, diffy = unpack(arg)
		if not touch then
			self._to._oldX = x
			self._to._oldY = y
		end
		
	elseif event == events.drag then
		local mB, x, y, diffx, diffy = unpack(arg)
		_dragging = true
		self._to.x = self._to.x + (x - self._to._oldX)
		self._to.y = self._to.y + (y - self._to._oldY)
		self._to._oldX = x
		self._to._oldY = y
		refresh()
	
	elseif event == events.mouseUp then
		_dragging = false
		refresh()
		
	end
end
function attachDragHandler(from, to)
	from._to = to
	from._dragHandler = _dragHandler
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

--Item
function Item.foreground(self)
	if not self.enabled then
		return colors.black
	elseif self._foreground then
		return self._foreground
	elseif self.parent then
		return self.parent:foreground()
	else
		return colors.white
	end
end
function Item.background(self)
	if not self.enabled then
		return colors.gray
	elseif self._background then
		return self._background
	elseif self.parent then
		return self.parent:background()
	else
		return colors.black
	end
end
function Item.isEnabled(self)
	if not self.parent then
		return self.enabled
	else
		return self.enabled and self.parent:isEnabled()
	end
end
function Item.isVisible(self)
	if not self.parent then
		return self.visible
	else
		return self.visible and self.parent:isVisible()
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
		r = math.max(math.center(self.bounds:x1(), self.bounds:x2(), #text - 0.5), self.bounds:x1())
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
	if not (_running and self:isVisible()) then
		return
	end
	
	--Values
	local x1, y1, x2, y2 = self.bounds:rect()
	local fg, bg = self:foreground(), self:background()
	if self:isInverted() then
		local tbg = bg
		bg = fg
		fg = tbg
	end
	
	--Paint background and borders
	if term.isColor() then
		if not _dragging then
			paintutils.drawFilledBox(x1, y1, x2, y2, bg)
			if self.image then
				paintutils.drawImage(self.image, x1, y1)
			end
			if self.border then
				paintutils.drawBox(x1 - 1, y1 - 1, x2 + 1, y2 + 1, self.border)
			elseif self.shadow then
				paintutils.drawLine(x2 + 1, y1 + 1, x2 + 1, y2, self.shadow)
				paintutils.drawLine(x1 + 1, y2 + 1, x2 + 1, y2 + 1, self.shadow)
			end
		else
			if self.shadow then
				paintutils.drawBox(x1 + 1, y1 + 1, x2 + 1, y2 + 1, self.shadow)
			end
			paintutils.drawBox(x1, y1, x2, y2, bg)
		end
	end
	
	--Write text
	if not _dragging and self.tLines and #self.tLines > 0 then
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
		end
	end
	
	--Paint content
	if not _dragging and self.items then
		for id, it in pairs(table.reverse(self.items, true)) do
			it:paint()
		end
	end
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
	if self.caretMove then
		self:caretMove()
	end
	self:paint()
	if _running then
		self:_valueChange(valueTypes.text)
	end
end

--Events
function Item._click(self, mB, x, y, diffx, diffy)
	if not self.enabled then
		return
	end
	
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	if self._dragHandler then
		self:_dragHandler(events.click, mB, x, y, diffx, diffy)
	end
	if self._eventHandler then
		if self:_eventHandler(events.click, mB, x, y, diffx, diffy) then
			return
		end
	end
	if _focused ~= nil and _focused ~= self then
		_focused:_focusOff()
	end
	self:_focusOn()
	if self.eClick then
		for k, e in pairs(self.eClick) do
			e(self, mB, diffx, diffy)
		end
	end
end
function Item._mouseUp(self, mB, x, y, diffx, diffy)
	if not self:isEnabled() then
		return
	end
	
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	if self._dragHandler then
		self:_dragHandler(events.mouseUp, mB, x, y, diffx, diffy)
	end
	if self._eventHandler then
		if self:_eventHandler(events.mouseUp, mB, x, y, diffx, diffy) then
			return
		end
	end
	if self.bounds:inside(x, y) and self.eMouseUp then
		for k, e in pairs(self.eMouseUp) do
			e(self, mB, x, y, diffx, diffy)
		end
	end
end
function Item._drag(self, mB, x, y, diffx, diffy)
	if not self:isEnabled() then
		return
	end
	
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	if self._dragHandler then
		self:_dragHandler(events.drag, mB, x, y, diffx, diffy)
	end
	if self._eventHandler then
		self:_eventHandler(events.drag, mB, x, y, diffx, diffy)
	end
	if self.eDrag then
		for k, e in pairs(self.eDrag) do
			e(self, mB, diffx, diffy)
		end
	end
end
function Item._scroll(self, dir, x, y, diffx, diffy)
	if not self:isEnabled() then
		return
	end
	
	diffx = (diffx or x) - self.x
	diffy = (diffy or y) - self.y
	
	if self._eventHandler then
		self:_eventHandler(events.scroll, dir, x, y, diffx, diffy)
	end
	if self.eScroll then
		for k, e in pairs(self.eScroll) do
			e(self, dir, diffx, diffy)
		end
	end
end
function Item._key(self, key, state)
	if not self:isEnabled() then
		return
	end
	
	if self._eventHandler then
		self:_eventHandler(events.key, key, state)
	end	
	if self.eKey then
		for k, e in pairs(self.eKey) do
			e(self, key, state)
		end
	end
end
function Item._text(self, text, paste)
	if not self:isEnabled() then
		return
	end
	
	if self._eventHandler then
		self:_eventHandler(events.text, text, paste)
	end
	if self.eText then
		for k, e in pairs(self.eText) do
			e(self, text, paste)
		end
	end
end
function Item._focusOn(self)
	if not self:isEnabled() then
		return
	end
	
	_focused = self
	if self._eventHandler then
		self:_eventHandler(events.focusOn)
	end
	if self.eFocusOn then
		for k, e in pairs(self.eFocusOn) do
			e(self)
		end
	end
end
function Item._focusOff(self)
	if not self:isEnabled() then
		return
	end
	
	_focused = nil
	if self._eventHandler then
		self:_eventHandler(events.focusOff)
	end
	if self.eFocusOff then
		for k, e in pairs(self.eFocusOff) do
			e(self)
		end
	end
end
function Item._valueChange(self, vtype)
	if not self:isEnabled() then
		return
	end
	if self.eValueChange then
		for k, e in pairs(self.eValueChange) do
			e(self, vtype)
		end
	end
end
function Item.uniEvent(self)
	self.eClick			= self.eClick or {}
	self.eMouseUp		= self.eMouseUp or {}
	self.eDrag			= self.eDrag or {}
	self.eScroll		= self.eScroll or {}
	self.eKey			= self.eKey or {}
	self.eText			= self.eText or {}
	self.eFocusOn		= self.eFocusOn or {}
	self.eFocusOff		= self.eFocusOff or {}
	self.eValueChange	= self.eValueChange or {}
end
function Item.remEvent(self, eType, event)
	self:uniEvent()
	if eType ~= nil and event ~= nil then
		if		eType == events.click		then table.remove(self.eClick, event)
		elseif	eType == events.mouseUp		then table.remove(self.eMouseUp, event)
		elseif	eType == events.drag		then table.remove(self.eDrag, event)
		elseif	eType == events.scroll		then table.remove(self.eScroll, event)
		elseif	eType == events.key			then table.remove(self.eKey, event)
		elseif	eType == events.text		then table.remove(self.eText, event)
		elseif	eType == events.focusOn		then table.remove(self.eFocusOn, event)
		elseif	eType == events.focusOff	then table.remove(self.eFocusOff, event)
		elseif	eType == events.valueChange	then table.remove(self.eValueChange, event)
		end
	end
end
function Item.addEvent(self, eType, event)
	self:uniEvent()
	if eType ~= nil and event ~= nil then
		if		eType == events.click		then table.insert(self.eClick, event)
		elseif	eType == events.mouseUp		then table.insert(self.eMouseUp, event)
		elseif	eType == events.drag		then table.insert(self.eDrag, event)
		elseif	eType == events.scroll		then table.insert(self.eScroll, event)
		elseif	eType == events.key			then table.insert(self.eKey, event)
		elseif	eType == events.text		then table.insert(self.eText, event)
		elseif	eType == events.focusOn		then table.insert(self.eFocusOn, event)
		elseif	eType == events.focusOff	then table.insert(self.eFocusOff, event)
		elseif	eType == events.valueChange	then table.insert(self.eValueChange, event)
		end
	end
end
function Item.new(x, y, text, w, h, fg, bg, border, _type, enabled)
	--print("New ", typeName(_type))
	--os.sleep(0.025)
	
	local i = {}
	i.bounds = Bounds.new(i)
	i.foreground = Item.foreground
	i.background = Item.background
	i.isEnabled = Item.isEnabled
	i.isVisible = Item.isVisible
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
	i.width = w or (text and string.lenX(text)) or 1
	i.height = h or (text and string.lenY(text)) or 1
	i._foreground = fg
	i._background = bg
	i.border = border
	i.shadow = nil
	i.enabled = enabled or true
	i.visible = true
	i._inverted = false
	i._type = _type
	i.alignX = nil
	i.alignY = nil
	i.image = nil
	
	i._eventHandler = nil
	i._click = Item._click
	i._mouseUp = Item._mouseUp
	i._drag = Item._drag
	i._scroll = Item._scroll
	i._key = Item._key
	i._text = Item._text
	i._focusOn = Item._focusOn
	i._focusOff = Item._focusOff
	i._valueChange = Item._valueChange
	i.uniEvent = Item.uniEvent
	i.addEvent = Item.addEvent
	i.remEvent = Item.remEvent
	i.eClick = {}
	i.eMouseUp = {}
	i.eDrag = {}
	i.eScroll = {}
	i.eKey = {}
	i.eText = {}
	i.eFocusOn = {}
	i.eFocusOff = {}
	i.eValueChange = {}
	
	return i
end

--Button
function Button.eventHandler(self, event, ...)
	if event == events.click then
		local mB, x, y, diffx, diffy = unpack(arg)
		self._inverted = true
		self:paint()
		
	elseif event == events.mouseUp then
		self._inverted = false
		self:paint()
	
	end
end
function Button.new(x, y, text, w, h, fg, bg, eClick)
	local b = Item.new(x, y, text, w, h, fg, bg, nil, types.button)
	b._eventHandler = Button.eventHandler
	b:addEvent(events.mouseUp, eClick)
	return b
end

--Panel
function Panel.eventHandler(self, event, ...)
	if event == events.click then
		local mB, x, y, diffx, diffy = unpack(arg)
		for n, i in pairs(self.items) do
			if i.bounds:inside(x, y) then
				i:_click(mB, x, y, diffx, diffy)
				return true
			end
		end
		
	end
end
function Panel.addItem(self, it, name, noPaint)
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
		if not noPaint then
			refresh()
		end
	end
	return can
end
function Panel.addItems(self, items)
	for k, i in pairs(items) do
		self:addItem(i, k, true)
	end
	refresh()
end
function Panel.remItem(self, name)
	local is = self.items and self.items[name]
	if is then
		table.remove(self.items, name)
		refresh()
	end
	return is
end
function Panel.addControlBar(self, title, canClose, canDrag)
	local t, c;
	
	t = Label.new(0, 0, title, self.width - 3, 1, colors.white, colors.blue)
	if canClose then
		c = Button.new(self.width - 3, 0, "x", 3, 1, colors.white, colors.red,
			function()
				if self.parent then
					self.parent:remItem(self.name)
				else
					stop()
				end
			end
		)
	end
	if canDrag then
		attachDragHandler(t, self)
	end
	
	self.controlBox = {t, c}
	self:addItems(self.controlBox)
	
	return t, c;
end
function Panel.new(x, y, w, h, fg, bg, border)
	local p = Item.new(x, y, nil, w, h, fg, bg, border, types.panel)
	p._eventHandler = Panel.eventHandler
	p.items = {}
	p.addItem = Panel.addItem
	p.addItems = Panel.addItems
	p.remItem = Panel.remItem
	p.addControlBar = Panel.addControlBar
	return p
end

--TextBox
function TextBox.eventHandler(self, event, ...)
	if event == events.key then
		local key, state = unpack(arg)
		self:handleKey(key, state)
		
	elseif event == events.click then
		local mB, x, y, diffx, diffy = unpack(arg)
		self:caretMove(diffx, diffy, true)
		
	elseif event == events.scroll then
		local dir, x, y, diffx, diffy = unpack(arg)
		self._vY = self._vY + dir
		self:caretMove()
		
	elseif event == events.text then
		local text, paste = unpack(arg)
		self:addText(text, paste)
		
	elseif event == events.focusOn then
		self:caretUpdate()
		
	elseif event == events.focusOff then
		term.setCursorBlink(false)
		
	end
end
function TextBox.handleKey(self, key, state)
	local p1, p2, l1, l2, words
	if state == keyEvents.raw then
		if key == keys.backspace then
			if self._cX > 0 then
				p1, p2 = string.split(self:line(), self._cX)
				if keyIsDown(keys.leftCtrl) or keyIsDown(keys.rightCtrl) then
					words = string.multimatch(p1, unpack(_texts.words))[1]
					self:line(0, table.concat(words, "", 1, #words - 1) .. p2)
					self:caretMove(-(#(words[#words])))
				else
					self:line(0, p1:sub(1, #p1 - 1) .. p2)
					self:caretMove(-1)
				end
			elseif self._cY > 0 then
				l1, l2 = self:line(-1), self:line()
				self:line(-1, l1 .. l2)
				table.remove(self.tLines, self._cY + 1)
				self:caretMove(-#l2 - 1)
			end
			
		elseif key == keys.delete then
			if self._cX < #(self:line()) then
				p1, p2 = string.split(self:line(), self._cX)
				if keyIsDown(keys.leftCtrl) or keyIsDown(keys.rightCtrl) then
					words = string.multimatch(p2, unpack(_texts.words))[1]
					self:line(0, p1 .. table.concat(words, "", 2))
				else
					self:line(0, p1 .. p2:sub(2, #p2))
				end
				self:caretMove()
			elseif self._cY < #self.tLines then
				l1, l2 = self:line(), self:line(1)
				self:line(0, l1 .. l2)
				table.remove(self.tLines, self._cY + 2)
				self:caretMove()
			end
			
		elseif key == keys.tab then
			self:addText("  ")
			
		elseif key == keys.enter then
			local initSpace = string.match(self:line(), [[%s+]]) or ""
			self:addText("\n"..initSpace)
			
		elseif key == keys.home then
			self:caretMove(-self._cX)
			
		elseif key == keys["end"] then
			self:caretMove(#(self:line()) - self._cX)
			
		elseif key == keys.pageUp then
			self:caretMove(0, -self.height)
			
		elseif key == keys.pageDown then
			self:caretMove(0, self.height)
			
		elseif key == keys.up then
			if keyIsDown(keys.leftAlt) or keyIsDown(keys.rightAlt) then
				if self._cY > 0 then
					local l, lp = self:line(), self:line(-1)
					self:line(-1, l)
					self:line(0, lp)
					self:caretMove(0, -1, false, true)
				end
			else
				self:caretMove(0, -1)
			end
			
		elseif key == keys.down then
			if keyIsDown(keys.leftAlt) or keyIsDown(keys.rightAlt) then
				if self._cY < #self.tLines - 1 then
					local l, ln = self:line(), self:line(1)
					self:line(1, l)
					self:line(0, ln)
					self:caretMove(0, 1, false, true)
				end
			else
				self:caretMove(0, 1)
			end
			
		elseif key == keys.left then
			if keyIsDown(keys.leftCtrl) or keyIsDown(keys.rightCtrl) then
				p1, p2 = string.split(self:line(), self._cX)
				words = string.multimatch(p1, unpack(_texts.words))[1]
			end
			if words and #words > 0 then
				self:caretMove(-(#(words[#words])))
			else
				self:caretMove(-1)
			end
			
		elseif key == keys.right then
			if keyIsDown(keys.leftCtrl) or keyIsDown(keys.rightCtrl) then
				p1, p2 = string.split(self:line(), self._cX)
				words = string.multimatch(p2, unpack(_texts.words))[1]
			end
			if words and #words > 0 then
				self:caretMove(#(words[1]))
			else
				self:caretMove(1)
			end
			
		end
	end
end
function TextBox.caretPos(self)
	return (self._cX - self._vX), (self._cY - self._vY)
end
function TextBox.caretFinal(self)
	local cx, cy = self:caretPos()
	return self.bounds:x1() + cx, self.bounds:y1() + cy
end
function TextBox.caretUpdate(self)
	local fX, fY = self:caretFinal()
	local ok = (_focused ~= nil
			and _focused == self
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
function TextBox.addText(self, text, paste)
	--LONG\nTEXT\nOVER\nMULTIPLE\nLINES
	--Becouse CC doesn't allow multiline paste
	if paste and self.parseNewLine then
		text = string.replace(text, "\\n", "\n")
	end
	local chrz = string.chars(text)
	for i, c in pairs(chrz) do
		if c == "\n" then
			self:addLine()
		else
			local p1, p2 = string.split(self:line(0), self._cX)
			self:line(0, p1 .. c .. p2)
			self:caretMove(1)
		end
	end
	self:txtFix()
	self:caretMove()
	if _running then
		self:_valueChange(valueTypes.text)
	end
end
function TextBox.addLine(self)
	if self.multiLine then
		local p1, p2 = string.split(self:line(), self._cX)
		self:line(0, p1)
		table.insert(self.tLines, self._cY + 2, p2)
		self:caretMove(-#p1, 1)
		if _running then
			self:_valueChange(valueTypes.text)
		end
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
function TextBox.new(x, y, text, w, h, fg, bg, multi)
	text = text or ""
	
	local t = Item.new(x, y, text, w, h, fg, bg, nil, types.textBox)
	t._vX = 0
	t._vY = 0
	t._cX = 0
	t._cY = 0
	t.multiLine = multi or string.contains(text, "\n")
	t.parseNewLine = true
	
	t._eventHandler = TextBox.eventHandler
	t.viewPosX = TextBox.viewPosX
	t.viewPosY = TextBox.viewPosY
	t.caretPos = TextBox.caretPos
	t.caretFinal = TextBox.caretFinal
	t.caretUpdate = TextBox.caretUpdate
	t.caretMove = TextBox.caretMove
	t.addText = TextBox.addText
	t.addLine = TextBox.addLine
	t.handleKey = TextBox.handleKey
	t.line = TextBox.line
	return t
end

--NumBox
function NumBox.eventHandler(self, event, ...)
	if event == events.key then
		local key, state = unpack(arg)
		self:handleKey(key, state)
		
	elseif event == events.scroll then
		local dir, x, y, diffx, diffy = unpack(arg)
		self:changeNum(self.step * -dir)
		
	elseif event == events.text then
		local text, paste = unpack(arg)
		if #(string.remChars(text, "0123456789")) > 0 then
			if text == "-" then
				self:setNum(-self.num)
			elseif text == "+" then
				self:setNum(math.abs(self.num))
			end
		else
			self:setNum(self.num..text)
		end
	
	elseif event == events.focusOn then
		self:caretUpdate()
		term.setCursorBlink(true)
		
	elseif event == events.focusOff then
		term.setCursorBlink(false)
		
	end
end
function NumBox.handleKey(self, key, state)
	if state == keyEvents.raw then
		if key == keys.up then
			self:changeNum(self.step)
			
		elseif key == keys.down then
			self:changeNum(-self.step)
			
		elseif key == keys.backspace then
			local s = self.num..""
			self:setNum(string.sub(s, 1, #s - 1))
			
		end
	end
end
function NumBox.changeNum(self, step)
	if keyIsDown(keys.leftCtrl) or keyIsDown(keys.rightCtrl) then
		step = step * 2
	end
	if keyIsDown(keys.leftShift) or keyIsDown(keys.rightShift) then
		step = step / 2
	end
	if self.noFloat then
		step = math.ceil(step)
	end
	self:setNum(self.num + step)
end
function NumBox.setNum(self, num)
	if type(num) == "string" then
		self.num = tonumber(num) or 0
	else
		self.num = num
	end
	self.num = math.between(self.nmin, self.num, self.nmax)
	self:setText(self.num.."")
	self:caretUpdate()
	if _running then
		self:_valueChange(valueTypes.number)
	end
end
function NumBox.caretUpdate(self)
	term.setCursorPos(math.min(self.bounds:x1() + #(self.num..""), self.bounds:x2()), self.bounds:y1())
end
function NumBox.new(x, y, num, nmin, nmax, step, noFloat, w, h, fg, bg)
	num  = num or 0
	nmin = nmin or 0
	nmax = nmax or 0
	step = step or 1
	
	local n = Item.new(x, y, num.."", w, h, fg, bg, nil, types.numBox)
	n.nmin = nmin
	n.nmax = nmax
	n.step = step or 1
	n.num = math.between(nmin, num, nmax)
	n.noFloat = noFloat
	n.alignX = align.topLeft
	
	n._eventHandler = NumBox.eventHandler
	n.handleKey = NumBox.handleKey
	n.changeNum = NumBox.changeNum
	n.setNum = NumBox.setNum
	n.caretUpdate = NumBox.caretUpdate
	
	return n
end

--CheckBox
function CheckBox.eventHandler(self, event, ...)
	if event == events.click then
		self:setChecked(not self.checked)
		
	end
end
function CheckBox.setChecked(self, state)
	self.checked = state
	self._foreground = state and self.foregroundT or self._background
	self:paint()
	if _running then
		self:_valueChange(valueTypes.checked)
	end
end
function CheckBox.new(x, y, checked, fg, bg)
	local c = Item.new(x, y, "#", 1, 1, checked and fg or bg, bg, nil, types.checkBox)
	c.foregroundT = fg
	c.checked = checked
	
	c._eventHandler = CheckBox.eventHandler
	c.setChecked = CheckBox.setChecked
	
	return c
end

--Timer
function Timer.start(self)
	self.enabled = true
	self.id = os.startTimer(self.tick)
	_runningTimers[self.id] = self
end
function Timer.stop(self)
	os.cancelTimer(self.id)
	self.enabled = false
	_runningTimers[self.id] = nil
	self.id = nil
end
function Timer.raise(self)
	os.cancelTimer(self.id)
	_runningTimers[self.id] = nil
	if self.enabled then
		self.id = os.startTimer(self.tick)
		_runningTimers[self.id] = self
		if self.action then
			self.action(unpack(self.params))
		end
	end
end
function Timer.new(sec, started, eTick, ...)
	local t = {}
	t.tick = sec
	t.enabled = false
	t.action = eTick
	t.params = arg
	
	t.start = Timer.start
	t.stop = Timer.stop
	t.raise = Timer.raise
	
	if started then
		t:start()
	end
	return t
end

--Dialog
function Dialog.show(self)
	if shownDialog == nil then
		shownDialog = self
		self.visible = true
		refresh()
	end
end
function Dialog.close(self, result)
	if shownDialog == self then
		shownDialog = nil
		self.visible = false
		refresh()
		if self.event then
			if self.txt then
				self:event(result, self.txt:getText())
			else
				self:event(result)
			end
		end
	end
end
function Dialog._click(self)
	self.dialog:close(self.result)
end
function Dialog.new(delegate, message, buttonStyle, isPrompt, title)
	if (not buttonStyle) or buttonStyle < 1 or buttonStyle > 6 then
		buttonStyle = buttonStyles.OK
	end
	message = message or ""
	title = title or ""
	isPrompt = isPrompt or false
	
	local d = Panel.new(0, 0, 8, 5, colors.black, colors.lightGray)
	d.shadow = colors.gray
	local dialogW
	local dialogH = 0
	
	local bar, _ = d:addControlBar(title, false, true)
	dialogH = math.max(dialogH, bar.y + bar.height)
	local msg = Label.new(1, dialogH + 1, message, nil, nil, colors.black)
	dialogH = math.max(dialogH, msg.y + msg.height)
	local txt
	if isPrompt then
		txt = TextBox.new(1, dialogH, "", math.max(8, msg.width), 1, colors.black, colors.white)
		dialogH = math.max(dialogH, txt.y + txt.height)
	end
	local pbtns = Panel.new(1, dialogH + 2, 1, 1)
	dialogH = math.max(dialogH, pbtns.y + pbtns.height)
	
	local btns = {}
	for _, dR in pairs(_styleResult[buttonStyle]) do
		local btxt = _texts.dialogBtns[dR]
		local x2 = (#btns > 0) and (btns[#btns].x + btns[#btns].width) or -1
		local btn = Button.new(x2 + 1, 0, btxt, math.min(#btxt + 2, 8), 1, colors.white, colors.brown, Dialog._click)
		btn.dialog = d
		btn.result = dR
		table.insert(btns, btn)
	end
	pbtns:addItems(btns)
	pbtns.width = btns[#btns].x + btns[#btns].width
	
	local dialogW = math.max(d.width, bar.width, msg.width + 2, isPrompt and txt.width + 2 or 0, pbtns.width + 2)
	bar.width = dialogW
	attachDragHandler(bar, d)
	if isPrompt then
		txt.width = dialogW - 2
	end
	pbtns.x = dialogW - pbtns.width - 1
	pbtns.y = dialogH - 2
	d.width = dialogW
	d.height = dialogH
	local tw, th = term.getSize()
	d.x = math.center(0, tw, d.width)
	d.y = math.center(0, th, d.height)
	d.visible = false
	d.event = delegate
	d.txt = txt
	d:addItems({bar, msg, txt, pbtns})
	
	d.show = Dialog.show
	d.close = Dialog.close
	
	return d
end

-- ...
function Label.new(x, y, text, w, h, fg, bg)
	local l = Item.new(x, y, text, w, h, fg, bg, nil, types.label)
	return l
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
function init(fg, bg, size)
	print("Form Init")
	local tw, th = term.getSize()
	local w, h = 0, 0
	if not size then
		w, h = tw, th
	else
		w, h = size.w, size.h
	end
	mainPanel = Panel.new(math.center(1, tw, w), math.center(1, th, h), w, h, fg or colors.white, bg or colors.black)
	mainPanel.shadow = colors.gray
end
function click(mButton, x, y)
	if _dragging then
		return
	end
	if shownDialog then
		shownDialog:_click(mButton, x, y)
	else
		mainPanel:_click(mButton, x, y)
	end
end
function refresh()
	if _running then
		term.setBackgroundColor(colors.black)
		term.clear()
		mainPanel:paint()
		if shownDialog then
			shownDialog:paint()
		end
	end
end
function run()
	_running = true
	term.setCursorPos(1, 1)
	term.setCursorBlink(false)
	refresh()
	while true do
		local event, p1, p2, p3, p4, p5 = os.pullEvent()
		if event == "mouse_click" then
			--mButton, x, y
			click(p1, p2, p3)
		elseif event == "mouse_up" then
			--mButton, x, y
			if _focused then
				_focused:_mouseUp(p1, p2, p3)
			end
		elseif event == "mouse_drag" then
			--mButton, x, y
			if _focused then
				_focused:_drag(p1, p2, p3)
			end
		elseif event == "mouse_scroll" then
			-- +1 Down / -1 Up, x, y1
			if _focused then
				_focused:_scroll(p1, p2, p3)
			end
		elseif event == "monitor_touch" then
			--mButton, x, y
			click(p1, p2, p3)
			os.sleep(0.05)
			if _focused then
				_focused:_mouseUp(p1, p2, p3)
			end
		elseif event == "char" or event == "paste" then
			--p1 = letter / text
			if _focused then
				_focused:_text(p1, event == "paste")
			end
		elseif event == "key" then
			--keyNumber, repeat
			if _keysTemp[p1] ~= nil and _keysTemp[p1] then
				--if key is pressed and repeating
				if p2 then
					os.queueEvent("managed_key", keyNumber, keyEvents.hold)
				end
			end
			_keysTemp[p1] = p2
			if _focused then
				_focused:_key(p1, keyEvents.raw)
			end
		elseif event == "key_up" then
			--keyNumber
			if _keysTemp[p1] ~= nil and not _keysTemp[p1] then
				--if key is pressed and released
				os.queueEvent("managed_key", keyNumber, keyEvents.press)
			end
			_keysTemp[p1] = nil
			os.queueEvent("managed_key", keyNumber, keyEvents.up)
		elseif event == "managed_key" then
			--keyNumber, keyState
			if _focused then
				_focused:_key(p1, p2)
			end
		elseif event == "timer" then
			--timerID
			if _runningTimers[p1] then
				_runningTimers[p1]:raise()
			end
		elseif event == "term_resize" then
			if _focused then
				_focused:_focusOff()
			end
			mainPanel.width, mainPanel.height = term.getSize()
			term.wash()
			refresh()
		elseif event == "forms_stop" then
			term.wash()
			return
		end
	end
end
function stop()
	os.queueEvent("forms_stop")
	__forms = nil
end
