function randomFromList(list)
	local chosenElement = math.ceil(math.random()*#list)
	return list[chosenElement], chosenElement
end

function insertAtRandom(list, element)
	local pos = math.floor(math.random()*#list) + 1
	table.insert(list, pos, element)
end

function explodingDice(sides)
	local number = math.ceil(math.random()*sides)
	if number == sides then
		return number - 1 + explodingDice(sides)
	else
		return number
	end
end

function plusOrMinus()
	local sign = 1
	if math.random() < 0.5 then
		sign = -1
	end
	return sign
end

function findSign(number)
	if number == 0 then
		return 0
	else
		return number/math.abs(number)
	end
end

function checkEven(number)
	if math.ceil(number/2) == number/2 then
		return true
	else
		return false
	end
end

function roundNumber(n)
	local point = n - math.floor(n)
	if point >= 0.5 then
		return math.ceil(n)
	else
		return math.floor(n)
	end
end

function orthogonalizeAngle(angle)
	while angle > math.pi do
		angle = angle - 2*math.pi
	end
	while angle < -math.pi do
		angle = angle + 2*math.pi
	end
	
	if angle > -3*math.pi/4 and angle <= -math.pi/4 then
		return -math.pi/2
	elseif angle > -math.pi/4 and angle <= math.pi/4 then
		return 0
	elseif angle > math.pi/4 and angle <= 3*math.pi/4 then
		return math.pi/2
	else
		return math.pi
	end
end

function findTileAtAngle(angle)
	while angle > math.pi do
		angle = angle - 2*math.pi
	end
	while angle < -math.pi do
		angle = angle + 2*math.pi
	end
	
	if angle > -7*math.pi/8 and angle <= -5*math.pi/8 then
		return -1, -1
	elseif angle > -5*math.pi/8 and angle <= -3*math.pi/8 then
		return 0, -1
	elseif angle > -3*math.pi/8 and angle <= -math.pi/8 then
		return 1, -1
	elseif angle > -math.pi/8 and angle <= math.pi/8 then
		return 1, 0
	elseif angle > math.pi/8 and angle <= 3*math.pi/8 then
		return 1, 1
	elseif angle > 3*math.pi/8 and angle <= 5*math.pi/8 then
		return 0, 1
	elseif angle > 5*math.pi/8 and angle <= 7*math.pi/8 then
		return -1, 1
	else
		return -1, 0
	end
end

function determineDiagonal(angle)
	local x, y = findTileAtAngle(angle)
	return math.abs(x) + math.abs(y) == 2
end

function flipBoolean(bool)
	if bool then
		return false
	else
		return true
	end
end

function binaryInsert(array, sortingElement, element, ascending)
	local back = 1
	local front = #array
	local elementOrder = element[sortingElement]
	local position = false
	while back <= front and not position do
		local mid = math.ceil((back + front)/2)
		local order = array[mid][sortingElement]
		if order > elementOrder then
			if ascending then
				front = mid - 1
			else
				back = mid + 1
			end
		elseif order < elementOrder then
			if ascending then
				back = mid + 1
			else
				front = mid - 1
			end
		else
			position = mid
		end
	end
	
	if not position then
		position = math.ceil((back + front)/2)
	end
	
	table.insert(array, position, element)
end

function findCartesianDistance(x1, y1, x2, y2)
	return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
end

function findOrthogonalDistance(x1, y1, x2, y2)
	return math.abs(x1 - x2) + math.abs(y1 - y2)
end

function checkCharacterInRange(cha)
	if string.byte(cha) >= 97 and string.byte(cha) <= 122 then
		return true
	end
	return false
end

function findTileSquare(xCenter, yCenter, radius)
	local determineTile = function(n, r)
		if n <= 2*r + 1 then
			local x = n - r - 1
			return x, -r
		elseif n <= 4*r + 1 then
			n = n - 2*r - 1
			local y = n - r
			return r, y
		elseif n <= 6*r + 1 then
			n = n - 4*r - 1
			local x = n - r - 1
			return x, r
		else
			n = n - 6*r - 1
			local y = n - r
			return -r, y
		end
	end
	
	local tileList = {}
	for n = 1, 8*radius do
		local x, y = determineTile(n, radius)
		table.insert(tileList, {x + xCenter, y + yCenter})
	end
	return tileList
end

function listLetterRange(list)
	local letter1 = 'a'
	local letter2 = string.char(#list + 96)
	if #list == 0 then
		return '(No books held)'
	else
		return '(' .. letter1 .. ' - ' .. letter2 .. ')'
	end
end

function shortenTextToSize(text, size, letterSize)
	local stringSize = #text*letterSize
	if stringSize <= size then
		return text
	else
		local maxCharacters = math.floor(size/letterSize)
		local shortenedText = string.sub(text, 1, maxCharacters - 3)
		shortenedText = shortenedText .. '...'
		return shortenedText
	end
end