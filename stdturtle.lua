--STD addon for Turtles by Microeinstein

loadfile("std")()

turtle.faces = turtle.faces or {
	N = 0,
	E = 1,
	S = 2,
	W = 3,
	U = 4,
	D = 5
}
turtle.side = turtle.side or 0
turtle.oldSlot = turtle.oldSlot or {x = 1, y = 1}
turtle.slot = turtle.slot or {x = 1, y = 1}

function turtle.getSlotN(x, y)
	return math.xyToNum(x, y, 4)
end
function turtle.getSlotXY(n)
	return math.numToXY(n, 4)
end
function turtle.setSlot(x, y)
	turtle.oldSlot = turtle.slot
	turtle.slot = {x = x, y = y}
	return turtle.select(turtle.getSlotN(x, y))
end
function turtle.setSlotTemp(x, y)
	return turtle.select(turtle.getSlotN(x, y))
end
function turtle.getSelected()
	return turtle.getSlotXY(turtle.getSelectedSlot())
end
function turtle.setSelected()
	return turtle.setSlotTemp(turtle.slot.x, turtle.slot.y)
end
function turtle.selectOld()
	local new = turtle.slot
	turtle.slot = turtle.oldSlot
	turtle.oldSlot = new
	return turtle.select(turtle.getSlotN(turtle.slot.x, turtle.slot.y))
end

function turtle.getItemDetailXY(x, y)
	return turtle.getItemDetail(turtle.getSlotN(x, y))
end
function turtle.getItemCountXY(x, y)
	return turtle.getItemCount(turtle.getSlotN(x, y))
end
function turtle.getItemSpaceXY(x, y)
	return turtle.getItemSpace(turtle.getSlotN(x, y))
end
function turtle.moveSlot(x, y, amount)
	if amount then
		return turtle.transferTo(turtle.getSlotN(x, y), amount)
	else
		return turtle.transferTo(turtle.getSlotN(x, y))
	end
end
function turtle.moveSlot(x1, y1, x2, y2, amount)
	local r
	turtle.setSlotTemp(x1, y1)
	if amount then
		r = turtle.transferTo(turtle.getSlotN(x2, y2), amount)
	else
		r = turtle.transferTo(turtle.getSlotN(x2, y2))
	end
	return r
end

function turtle.turnSide(side)
	side = side - math.floor(side / 4) * 4
	if turtle.side - 3 == side then
		turtle.turnRight()
	elseif turtle.side < side then
		for r = turtle.side, side, 1 do
			turtle.turnRight()
		end
	elseif turtle.side > side then
		for r = turtle.side, side, -1 do
			turtle.turnLeft()
		end
	end
	turtle.side = side
end

function turtle.pull(x, y, face, amount)
	local r
	turtle.setSlotTemp(x, y)
	if amount then
		if face == 4 then
			r = turtle.suckUp(amount)
		elseif face == 5 then
			r = turtle.suckDown(amount)
		else
			turtle.turnSide(face)
			r = turtle.suck(amount)
		end
	else
		if face == 4 then
			r = turtle.suckUp()
		elseif face == 5 then
			r = turtle.suckDown()
		else
			turtle.turnSide(face)
			r = turtle.suck()
		end
	end
	return r
end
function turtle.push(x, y, face, amount)
	local r
	turtle.setSlotTemp(x, y)
	if amount then
		if face == 4 then
			r = turtle.dropUp(amount)
		elseif face == 5 then
			r = turtle.dropDown(amount)
		else
			turtle.turnSide(face)
			r = turtle.drop(amount)
		end
	else
		if face == 4 then
			r = turtle.dropUp()
		elseif face == 5 then
			r = turtle.dropDown()
		else
			turtle.turnSide(face)
			r = turtle.drop()
		end
	end
	return r
end
