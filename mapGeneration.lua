local findCornerRotation = function(tiles, x, y, mergeProperties)
	local top = tiles[x]
	if top then
		top = checkProperties(top[y - 1], mergeProperties)
	else
		top = false
	end
	local bot = tiles[x]
	if bot then
		bot = checkProperties(bot[y + 1], mergeProperties)
	else
		bot = false
	end
	local left = tiles[x - 1]
	if left then
		left = checkProperties(left[y], mergeProperties)
	else
		left = false
	end
	local right = tiles[x + 1]
	if right then
		right = checkProperties(right[y], mergeProperties)
	else
		right = false
	end
	
	if top then
		if left then
			return 0
		elseif right then
			return 1
		end
	elseif bot then
		if left then
			return 3
		elseif right then
			return 2
		end
	end
	return 0
end

local mapRectangle = function(tiles, sX, eX, sY, eY, floorTile, wallTile, floorImage, wallImage, border)
	for i = sX, eX do
		for j = sY, eY do
			local nTile = 0
			if i == sX or i == eX or j == sY or j == eY then
				nTile = newTile(wallTile, wallImage)
				if border then
					nTile.tile = setTileProperties(nTile, {border = true})
				end
			else
				nTile = newTile(floorTile, floorImage)
			end
			
			if tiles[i] == nil then
				tiles[i] = {}
			end
			if tiles[i][j] == nil then
				tiles[i][j] = nTile
			else
				if tiles[i][j].tileName ~= floorTile or nTile.tileName ~= wallTile then
					tiles[i][j] = nTile
				end
			end
		end
	end
end

local mapPillar = function(tiles, sX, eX, sY, eY, cornerSize, floorTile, wallTile, cornerTile, floorImage, wallImage, cornerImage)
	local cX = (sX + eX)/2
	local cY = (sY + eY)/2
	for x = sX, eX do
		for y = sY, eY do
			local cornerDistance = math.min(math.abs(sX - x) + math.abs(sY - y), math.abs(eX - x) + math.abs(sY - y), math.abs(sX - x) + math.abs(eY - y), math.abs(eX - x) + math.abs(eY - y))
			
			local nTile = 0
			if cornerDistance > cornerSize then
				nTile = newTile(wallTile, wallImage)
			elseif cornerDistance == cornerSize then
				nTile = newTile(cornerTile, cornerImage)
				if x < cX and y < cY then
					setTileProperties(nTile, {angle = 2})
				elseif x > cX and y < cY then
					setTileProperties(nTile, {angle = 3})
				elseif x < cX and y > cY then
					setTileProperties(nTile, {angle = 1})
				end
			else
				nTile = newTile(floorTile, floorImage)
			end
			
			if tiles[x] == nil then
				tiles[x] = {}
			end
			tiles[x][y] = nTile
		end
	end
end

local prepareSpace = function(tiles, sX, eX, sY, eY, tile, image)
	for i = sX, eX do
		for j = sY, eY do
			if tiles[i] == nil then
				tiles[i] = {}
			end
			tiles[i][j] = newTile(tile, image)
		end
	end
end


local smallRectangleRoom = function()
	local xSize = 5 + math.floor(math.random()*6)
	local ySize = 5 + math.floor(math.random()*6)
	
	local tiles = {}
	local sX = -math.floor(xSize/2)
	local sY = -math.floor(ySize/2)
	local eX = sX + xSize - 1
	local eY = sY + ySize - 1
	mapRectangle(tiles, sX, eX, sY, eY, 'floor', 'wall', 'images/tiles/floor.png', 'images/tiles/wall.png', true)
	
	tiles[sX + 1][sY + 1] = newTile('cornerWall', 'images/tiles/corner.png')
	tiles[eX - 1][sY + 1] = newTile('cornerWall', 'images/tiles/corner.png')
	setTileProperties(tiles[eX - 1][sY + 1], {angle = 1})
	tiles[eX - 1][eY - 1] = newTile('cornerWall', 'images/tiles/corner.png')
	setTileProperties(tiles[eX - 1][eY - 1], {angle = 2})
	tiles[sX + 1][eY - 1] = newTile('cornerWall', 'images/tiles/corner.png')
	setTileProperties(tiles[sX + 1][eY - 1], {angle = 3})
	
	local largestSize = 3
	local entrances = {}
	local i = sX + 2
	while i < eX - 1 do
		local maxSize = eX - i - 1
		if maxSize > largestSize then
			maxSize = largestSize
		end
		local chosenSize = math.ceil(math.random()*maxSize)
		
		local entranceTiles = {}
		for j = 0, chosenSize - 1 do
			table.insert(entranceTiles, {i + j, sY})
		end
		table.insert(entrances, newEntrance(entranceTiles, 0, -1, chosenSize, 'floor', 'images/tiles/floor.png'))
		
		i = i + chosenSize + 1
	end
	
	i = sX + 2
	while i < eX - 1 do
		local maxSize = eX - i - 1
		if maxSize > largestSize then
			maxSize = largestSize
		end
		local chosenSize = math.ceil(math.random()*maxSize)
		
		local entranceTiles = {}
		for j = 0, chosenSize - 1 do
			table.insert(entranceTiles, {i + j, eY})
		end
		table.insert(entrances, newEntrance(entranceTiles, 0, 1, chosenSize, 'floor', 'images/tiles/floor.png'))
		
		i = i + chosenSize + 1
	end
	
	i = sY + 2
	while i < eY - 1 do
		local maxSize = eY - i - 1
		if maxSize > largestSize then
			maxSize = largestSize
		end
		local chosenSize = math.ceil(math.random()*maxSize)
		
		local entranceTiles = {}
		for j = 0, chosenSize - 1 do
			table.insert(entranceTiles, {sX, i + j})
		end
		table.insert(entrances, newEntrance(entranceTiles, -1, 0, chosenSize, 'floor', 'images/tiles/floor.png'))
		
		i = i + chosenSize + 1
	end
	
	i = sY + 2
	while i < eY - 1 do
		local maxSize = eY - i - 1
		if maxSize > largestSize then
			maxSize = largestSize
		end
		local chosenSize = math.ceil(math.random()*maxSize)
		
		local entranceTiles = {}
		for j = 0, chosenSize - 1 do
			table.insert(entranceTiles, {eX, i + j})
		end
		table.insert(entrances, newEntrance(entranceTiles, 1, 0, chosenSize, 'floor', 'images/tiles/floor.png'))
		
		i = i + chosenSize + 1
	end
	
	return newRoom(tiles, entrances, sX, sY, eX, eY)
end

local corridorRoom = function()
	local width = math.ceil(math.random()*3) + 3
	local length = 5 + math.ceil(math.random()*3)
	
	local xSize = width
	local ySize = length
	if math.random() < 0.5 then
		xSize = length
		ySize = width
	end
	
	local tiles = {}
	local sX = -math.floor(xSize/2)
	local sY = -math.floor(ySize/2)
	local eX = sX + xSize - 1
	local eY = sY + ySize - 1
	mapRectangle(tiles, sX, eX, sY, eY, 'floor', 'wall', 'images/tiles/floor.png', 'images/tiles/wall.png', true)
	mapRectangle(tiles, sX, eX, sY, eY, 'floor', 'wall', 'images/tiles/floor.png', 'images/tiles/wall.png', true)
	
	local entrances = {}
	if xSize > ySize then
		local startTiles = {}
		local endTiles = {}
		for i = 1, width - 2 do
			table.insert(startTiles, {sX, sY + i})
			table.insert(endTiles, {eX, sY + i})
		end
		table.insert(entrances, newEntrance(startTiles, -1, 0, width - 2, 'floor', 'images/tiles/floor.png'))
		table.insert(entrances, newEntrance(endTiles, 1, 0, width - 2, 'floor', 'images/tiles/floor.png'))
	else
		local startTiles = {}
		local endTiles = {}
		for i = 1, width - 2 do
			table.insert(startTiles, {sX + i, sY})
			table.insert(endTiles, {sX + i, eY})
		end
		table.insert(entrances, newEntrance(startTiles, 0, -1, width - 2, 'floor', 'images/tiles/floor.png'))
		table.insert(entrances, newEntrance(endTiles, 0, 1, width - 2, 'floor', 'images/tiles/floor.png'))
	end
	
	
	return newRoom(tiles, entrances, sX, sY, eX, eY)
end

local oneKinkCorriodor = function()
	local corridorWidth = math.ceil(math.random()*3) + 1
	local width = 2 + corridorWidth + math.ceil(math.random()*4)
	local height = 2 + corridorWidth + math.ceil(math.random()*4)
	corridorWidth = corridorWidth + 1
	
	local tiles = {}
	local sX = -math.floor(width/2)
	local sY = -math.floor(height/2)
	local eX = sX + width - 1
	local eY = sY + height - 1
	prepareSpace(tiles, sX, eX, sY, eY, 'unFilled', 'images/tiles/baseTile.png')
	
	local topY = sY
	if math.random() < 0.5 then
		topY = eY - corridorWidth
	end
	mapRectangle(tiles, sX, eX, topY, topY + corridorWidth, 'floor', 'wall', 'images/tiles/floor.png', 'images/tiles/wall.png', true)
	
	local leftX = sX
	if math.random() < 0.5 then
		leftX = eX - corridorWidth
	end
	mapRectangle(tiles, leftX, leftX + corridorWidth, sY, eY, 'floor', 'wall', 'images/tiles/floor.png', 'images/tiles/wall.png', true)
	
	local entrances = {}
	local startTiles = {}
	local endTiles = {}
	for i = 1, corridorWidth - 1 do
		table.insert(startTiles, {sX, topY + i})
		table.insert(endTiles, {eX, topY + i})
	end
	table.insert(entrances, newEntrance(startTiles, -1, 0, corridorWidth - 1, 'floor', 'images/tiles/floor.png'))
	table.insert(entrances, newEntrance(endTiles, 1, 0, corridorWidth - 1, 'floor', 'images/tiles/floor.png'))
	
	startTiles = {}
	endTiles = {}
	for i = 1, corridorWidth - 1 do
		table.insert(startTiles, {leftX + i, sY})
		table.insert(endTiles, {leftX + i, eY})
	end
	table.insert(entrances, newEntrance(startTiles, 0, -1, corridorWidth - 1, 'floor', 'images/tiles/floor.png'))
	table.insert(entrances, newEntrance(endTiles, 0, 1, corridorWidth - 1, 'floor', 'images/tiles/floor.png'))
	
	return newRoom(tiles, entrances, sX, sY, eX, eY)
end

local straightAdapter = function()
	local width1 = math.ceil(math.random()*4) + 4
	local widthDifference = 2*math.ceil(math.random()*2)
	local width2 = width1 + plusOrMinus()*widthDifference
	
	while width2 < 3 do
		width1 = width1 + 2
		width2 = width2 + 2
	end
	
	local largestWidth = math.max(width1, width2)
	
	local redundantLength = math.ceil(math.random()*3)
	local length = 2 + widthDifference + 2*redundantLength
	
	redundantLength = redundantLength + 1
	
	local xSize = length
	local ySize = largestWidth
	local direction = 'lr'
	if math.random() < 0.5 then
		direction = 'tb'
	end
	
	local tiles = {}
	local sX = -math.floor(xSize/2)
	local sY = -math.floor(ySize/2)
	local eX = sX + xSize - 1
	local eY = sY + ySize - 1
	for i = sX, eX do
		local change = 2*((i - sX) - redundantLength)
		if change < 0 then
			change = 0
		elseif change > widthDifference then
			change = widthDifference
		end
		
		local topWidth = -math.floor((width1 + findSign(width2 - width1)*change)/2)
		local botWidth = math.floor((width1 + findSign(width2 - width1)*change)/2)
		if checkEven(width1) then
			botWidth = botWidth - 1
		end
		
		local cornerCutIn = redundantLength
		local cornerCutOut = redundantLength + widthDifference/2
		
		if width1 < width2 then
			cornerCutIn = cornerCutIn + 1
		else
			cornerCutOut = cornerCutOut - 1
		end
		
		for j = sY, eY do
			local tile = 'unFilled'
			local image = 'images/tiles/baseTile.png'
			
			if i == sX then
				if j >= topWidth and j <= botWidth then
					tile = 'wall'
					image = 'images/tiles/wall.png'
				end
			elseif i == eX then
				if j >= topWidth and j <= botWidth then
					tile = 'wall'
					image = 'images/tiles/wall.png'
				end
			else
				if j == topWidth or j == botWidth then
					tile = 'wall'
					image = 'images/tiles/wall.png'
				elseif j > topWidth and j < botWidth then
					tile = 'floor'
					image = 'images/tiles/floor.png'
				end
			end
			
			local lI = i
			local lJ = j
			if direction == 'tb' then
				lI = j
				lJ = i
			end
			if tiles[lI] == nil then
				tiles[lI] = {}
			end
			
			tiles[lI][lJ] = newTile(tile, image)
			if tile == 'wall' then
				tiles[lI][lJ].tile = setTileProperties(tiles[lI][lJ], {border = true})
			end
		end
	end
	
	--Add corners
	for i = sX, eX do
		local change = 2*((i - sX) - redundantLength)
		if change < 0 then
			change = 0
		elseif change > widthDifference then
			change = widthDifference
		end
		
		local topWidth = -math.floor((width1 + findSign(width2 - width1)*change)/2)
		local botWidth = math.floor((width1 + findSign(width2 - width1)*change)/2)
		if checkEven(width1) then
			botWidth = botWidth - 1
		end
		
		local cornerCutIn = redundantLength
		local cornerCutOut = redundantLength + widthDifference/2
		
		if width1 < width2 then
			cornerCutIn = cornerCutIn + 1
		else
			cornerCutOut = cornerCutOut - 1
		end
		
		for j = sY, eY do
			local lI = i
			local lJ = j
			if direction == 'tb' then
				lI = j
				lJ = i
			end
			
			if (j == topWidth + 1 or j == botWidth - 1) and (i - sX) >= cornerCutIn and (i - sX) <= cornerCutOut then
				tiles[lI][lJ] = newTile('cornerWall', 'images/tiles/corner.png')
				setTileProperties(tiles[lI][lJ], {angle = findCornerRotation(tiles, lI, lJ, {blocksWalker = true})})
			end
		end
	end
	--
	
	local entrances = {}
	if direction == 'lr' then
		local sTiles = {}
		for i = 1, width1 - 2 do
			local entranceY = math.floor(i/2)
			if checkEven(i) then
				entranceY = -entranceY
			end
			table.insert(sTiles, {sX, entranceY})
		end
		table.insert(entrances, newEntrance(sTiles, -1, 0, width1 - 2, 'floor', 'images/tiles/floor.png'))
		
		local eTiles = {}
		for i = 1, width2 - 2 do
			local entranceY = math.floor(i/2)
			if checkEven(i) then
				entranceY = -entranceY
			end
			table.insert(eTiles, {eX, entranceY})
		end
		table.insert(entrances, newEntrance(eTiles, 1, 0, width2 - 2, 'floor', 'images/tiles/floor.png'))
	else
		local lS = sX
		local lE = eX
		sX = sY
		eX = eY
		sY = lS
		eY = lE
		
		local sTiles = {}
		for i = 1, width1 - 2 do
			local entranceX = math.floor(i/2)
			if checkEven(i) then
				entranceX = -entranceX
			end
			table.insert(sTiles, {entranceX, sY})
		end
		table.insert(entrances, newEntrance(sTiles, 0, -1, width1 - 2, 'floor', 'images/tiles/floor.png'))
		
		local eTiles = {}
		for i = 1, width2 - 2 do
			local entranceX = math.floor(i/2)
			if checkEven(i) then
				entranceX = -entranceX
			end
			table.insert(eTiles, {entranceX, eY})
		end
		table.insert(entrances, newEntrance(eTiles, 0, 1, width2 - 2, 'floor', 'images/tiles/floor.png'))
	end
	
	return newRoom(tiles, entrances, sX, sY, eX, eY)
end

local grandHall = function()
	local corridorSize = math.ceil(math.random()*4) + 2
	local pillarSize = math.floor(math.random()*4)
	local pillarN = explodingDice(4)
	local pillarGap = math.ceil(math.random()*3)
	
	local length = (pillarSize + 2)*pillarN + pillarGap*(pillarN + 1) + 2
	local width = corridorSize + 2*(pillarSize + 2) + 2*pillarGap + 2
	
	local direction = 'lr'
	if math.random() < 0.5 then
		direction = 'td'
	end
	
	local xSize = length
	local ySize = width
	if direction == 'td' then
		xSize = width
		ySize = length
	end
	
	local tiles = {}
	local sX = -math.floor(xSize/2)
	local sY = -math.floor(ySize/2)
	local eX = sX + xSize - 1
	local eY = sY + ySize - 1
	mapRectangle(tiles, sX, eX, sY, eY, 'floor', 'wall', 'images/tiles/floor.png', 'images/tiles/wall.png', true)
	
	tiles[sX + 1][sY + 1] = newTile('cornerWall', 'images/tiles/corner.png')
	tiles[eX - 1][sY + 1] = newTile('cornerWall', 'images/tiles/corner.png')
	setTileProperties(tiles[eX - 1][sY + 1], {angle = 1})
	tiles[eX - 1][eY - 1] = newTile('cornerWall', 'images/tiles/corner.png')
	setTileProperties(tiles[eX - 1][eY - 1], {angle = 2})
	tiles[sX + 1][eY - 1] = newTile('cornerWall', 'images/tiles/corner.png')
	setTileProperties(tiles[sX + 1][eY - 1], {angle = 3})
	
	if direction == 'lr' then
		local startingPillarX = sX + pillarGap + 1
		local tY = sY + pillarGap + 1
		local bY = math.ceil(corridorSize/2)
		for i = 1, pillarN do
			local pX = startingPillarX + (i - 1)*(2 + pillarSize + pillarGap)
			mapPillar(tiles, pX, pX + pillarSize + 1, tY, tY + pillarSize + 1, 0, 'floor', 'wall', 'cornerWall', 'images/tiles/floor.png', 'images/tiles/wall.png', 'images/tiles/corner.png')
			mapPillar(tiles, pX, pX + pillarSize + 1, bY, bY + pillarSize + 1, 0, 'floor', 'wall', 'cornerWall', 'images/tiles/floor.png', 'images/tiles/wall.png', 'images/tiles/corner.png')
		end
	else
		local startingPillarY = sY + pillarGap + 1
		local tX = sX + pillarGap + 1
		local bX = math.ceil(corridorSize/2)
		for i = 1, pillarN do
			local pY = startingPillarY + (i - 1)*(2 + pillarSize + pillarGap)
			mapPillar(tiles, tX, tX + pillarSize + 1, pY, pY + pillarSize + 1, 0, 'floor', 'wall', 'cornerWall', 'images/tiles/floor.png', 'images/tiles/wall.png', 'images/tiles/corner.png')
			mapPillar(tiles, bX, bX + pillarSize + 1, pY, pY + pillarSize + 1, 0, 'floor', 'wall', 'cornerWall', 'images/tiles/floor.png', 'images/tiles/wall.png', 'images/tiles/corner.png')
		end
	end
	
	local entrances = {}
	if direction == 'lr' then
		local sTiles = {}
		local eTiles = {}
		for i = -math.floor(corridorSize/2), math.ceil(corridorSize/2) - 1 do
			local entranceY = i
			table.insert(sTiles, {sX, entranceY})
			table.insert(eTiles, {eX, entranceY})
		end
		table.insert(entrances, newEntrance(sTiles, -1, 0, corridorSize, 'floor', 'images/tiles/floor.png'))
		table.insert(entrances, newEntrance(eTiles, 1, 0, corridorSize, 'floor', 'images/tiles/floor.png'))
		
		local startingPillarX = -math.floor(pillarGap/2) - math.ceil(0.5*(2 + pillarSize + pillarGap)*(pillarN - 2))
		for p = 1, pillarN - 1 do
			local pX = startingPillarX + (p - 1)*(2 + pillarSize + pillarGap)
			sTiles = {}
			eTiles = {}
			for i = 0, pillarGap - 1 do
				local entranceX = pX + i
				table.insert(sTiles, {entranceX, sY})
				table.insert(eTiles, {entranceX, eY})
			end
			table.insert(entrances, newEntrance(sTiles, 0, -1, pillarGap, 'floor', 'images/tiles/floor.png'))
			table.insert(entrances, newEntrance(eTiles, 0, 1, pillarGap, 'floor', 'images/tiles/floor.png'))
		end
	else
		local sTiles = {}
		local eTiles = {}
		for i = -math.floor(corridorSize/2), math.ceil(corridorSize/2) - 1 do
			local entranceX = i
			table.insert(sTiles, {entranceX, sY})
			table.insert(eTiles, {entranceX, eY})
		end
		table.insert(entrances, newEntrance(sTiles, 0, -1, corridorSize, 'floor', 'images/tiles/floor.png'))
		table.insert(entrances, newEntrance(eTiles, 0, 1, corridorSize, 'floor', 'images/tiles/floor.png'))
		
		local startingPillarY = -math.floor(pillarGap/2) - math.ceil(0.5*(2 + pillarSize + pillarGap)*(pillarN - 2))
		for p = 1, pillarN - 1 do
			local pY = startingPillarY + (p - 1)*(2 + pillarSize + pillarGap)
			sTiles = {}
			eTiles = {}
			for i = 0, pillarGap - 1 do
				local entranceY = pY + i
				table.insert(sTiles, {sX, entranceY})
				table.insert(eTiles, {eX, entranceY})
			end
			table.insert(entrances, newEntrance(sTiles, -1, 0, pillarGap, 'floor', 'images/tiles/floor.png'))
			table.insert(entrances, newEntrance(eTiles, 1, 0, pillarGap, 'floor', 'images/tiles/floor.png'))
		end
	end
	
	return newRoom(tiles, entrances, sX, sY, eX, eY)
end

local roomSelectionArray = {}
table.insert(roomSelectionArray, {func = smallRectangleRoom, probability = 3})
table.insert(roomSelectionArray, {func = corridorRoom, probability = 3})
table.insert(roomSelectionArray, {func = straightAdapter, probability = 2})
table.insert(roomSelectionArray, {func = oneKinkCorriodor, probability = 3})
table.insert(roomSelectionArray, {func = grandHall, probability = 0.5})

function generateMap(nRooms, level)
	local map = newMap(1, 1, 'unFilled', 'images/tiles/baseTile.png')
	local rooms = {}
	local entrances = {}
	for i = 1, nRooms do
		generateRoom(map, rooms, entrances)
	end
	openSidePassages(map, rooms)
	determineTileImages(map)
	
	return map, rooms
end

function newRoom(tiles, entrances, sX, sY, eX, eY)
	local room = {tiles = tiles, x = nil, y = nil, entrances = entrances, corridor = corridor, tileTypes = {}, border = {}, adjacent = {}, distance = 0, sX = sX, sY = sY, eX = eX, eY = eY}
	for i = 1, #entrances do
		local entrance = entrances[i]
		local sortedTiles = {}
		entrance.parentRoom = room
		
		while #entrance.tiles > 0 do
			local bestI = nil
			for j = 1, #entrance.tiles do
				local tile = entrance.tiles[j]
				local bestTile = entrance.tiles[bestI]
				if bestI == nil then
					bestI = j
				else
					local bDist = bestTile[1] + bestTile[2]
					local dist = tile[1] + tile[2]
					if dist < bDist then
						bestI = j
					elseif dist == bDist then
						if tile[2] < bestTile[2] then
							bestI = j
						end
					end
				end
			end
			table.insert(sortedTiles, entrance.tiles[bestI])
			table.remove(entrance.tiles, bestI)
		end
		
		entrance.tiles = sortedTiles
	end
	return room
end

function newEntrance(tiles, xD, yD, size, tile, image)
	return {tiles = tiles, parentRoom = nil, xD = xD, yD = yD, size = size, tile = tile, image = image, used = false}
end

function generateRoom(map, rooms, entrances)
	local roomPlaced = false
	local iteration = 0
	while not roomPlaced do
		iteration = iteration + 1
		local totalProb = 0
		for i = 1, #roomSelectionArray do
			totalProb = totalProb + roomSelectionArray[i].probability
		end
		
		local room = math.random()*totalProb
		local i = 1
		while i < #roomSelectionArray do
			if roomSelectionArray[i].probability > room then
				break
			else
				room = room - roomSelectionArray[i].probability
				i = i + 1
			end
		end
		
		room = roomSelectionArray[i].func()
		
		if #rooms == 0 then
			placeRoom(map, room, nil, 0, 0)
			roomPlaced = true
		else
			local suitableEntrances = findSuitableEntrances(entrances, room.entrances)
			while #suitableEntrances > 0 do
				local entranceI, listI = randomFromList(suitableEntrances)
				local entrance = entrances[entranceI]
				local pX, pY = findPlacementLocation(map, room, entrance)
				
				if pX then
					placeRoom(map, room, entrance.parentRoom, pX, pY)
					openAdjacentRooms(map, room, entrances)
					table.remove(entrances, entranceI)
					roomPlaced = true
					break
				end
				table.remove(suitableEntrances, listI)
			end
		end
		
		if roomPlaced == true then
			table.insert(rooms, room)
			for i = 1, #room.entrances do
				if room.entrances[i].used == false then
					table.insert(entrances, room.entrances[i])
				end
			end
			return room
		end
		
		if iteration > 10000 then
			error('infinite loop in map generation')
		end
	end
end

function findSuitableEntrances(entrances1, entrances2)
	local suitableEntrances = {}
	for i = 1, #entrances1 do
		local entrance = entrances1[i]
		if not entrance.used then
			for j = 1, #entrances2 do
				local aEntrance = entrances2[j]
				if entrance.size == aEntrance.size and entrance.xD == -aEntrance.xD and entrance.yD == -aEntrance.yD and entrance.tile == aEntrance.tile then
					table.insert(suitableEntrances, i)
					break
				end
			end
		end
	end
	
	return suitableEntrances
end

function findPlacementLocation(map, room, entrance)
	local suitableEntrances = findSuitableEntrances(room.entrances, {entrance})
	
	local joiningEntrance = room.entrances[randomFromList(suitableEntrances)]
	
	local x = entrance.tiles[1][1] - joiningEntrance.tiles[1][1]
	local y = entrance.tiles[1][2] - joiningEntrance.tiles[1][2]
	
	local fitsX, fitsY = checkRoomFits(map, room, x, y)
	
	if fitsX == 0 and fitsY == 0 then
		joiningEntrance.used = true
		return x, y
	else
		return false, false
	end
end

function findRandomLocation(eX, eY, dX, dY, distance)
	local distance = explodingDice(distance)
	local xDistance = math.ceil(distance*((dX - 1) + 2*math.random()))
	local yDistance = math.ceil(distance*((dY - 1) + 2*math.random()))
	return eX + xDistance, eY + yDistance
end

function checkRoomFits(map, room, x, y)
	local xShift = 0
	local yShift = 0
	
	for i = room.sX, room.eX do
		for j = room.sY, room.eY do
			local mX = i + x
			local mY = j + y
			local mapTile = getTile(map, mX, mY)
			
			if not checkTilesIdentical(room.tiles[i][j], mapTile) and checkProperties(mapTile, {constructed = true}) and checkProperties(room.tiles[i][j], {constructed = true}) then
				local nXShift = i - room.eX - 1
				if i < 0 then
					nXShift = i - room.sX + 1
				end
				local nYShift = j - room.eY - 1
				if j < 0 then
					nYShift = j - room.sY + 1
				end
				
				if math.abs(nXShift) > math.abs(nYShift) then
					if math.abs(nXShift) > math.abs(xShift) then
						xShift = nXShift
					end
				else
					if math.abs(nYShift) > math.abs(yShift) then
						yShift = nYShift
					end
				end
			end
		end
	end
	return xShift, yShift
end

function placeRoom(map, room, adjacentRoom, x, y)
	room.x = x
	room.y = y
	
	if adjacentRoom then
		table.insert(room.adjacent, adjacentRoom)
		table.insert(adjacentRoom.adjacent, room)
		room.distance = adjacentRoom.distance + 1
	end
	
	for i = room.sX, room.eX do
		for j = room.sY, room.eY do
			local tile = room.tiles[i][j]
			if checkProperties(tile, {constructed = true}) then
				local mapTile = placeTile(map, tile, i + x, j + y)
				if not mapTile.tile.border then
					if not room.tileTypes[tile.tileName] then
						room.tileTypes[tile.tileName] = {}
					end
					table.insert(room.tileTypes[tile.tileName], mapTile)
				else
					table.insert(room.border, mapTile)
				end
			end
		end
	end
	
	for i = 1, #room.entrances do
		local entrance = room.entrances[i]
		for j = 1, #entrance.tiles do
			local entranceTile = entrance.tiles[j]
			entranceTile[1] = entranceTile[1] + x
			entranceTile[2] = entranceTile[2] + y
			
			if entrance.used == true then
				placeTile(map, newTile(entrance.tile, entrance.image), entranceTile[1], entranceTile[2])
			end
		end
	end
	
	--markRoomEntrances(map, room)
end

function openAdjacentRooms(map, room, entrances)
	for i = 1, #room.entrances do
		local entrance = room.entrances[i]
		if entrance.used == false then
			local possibleAdjacentEntrances = findSuitableEntrances(entrances, {entrance})
			for j = 1, #possibleAdjacentEntrances do
				local aEntrance = entrances[possibleAdjacentEntrances[j]]
				
				local matching = true
				for k = 1, #entrance.tiles do
					local tile = entrance.tiles[k]
					local aTile = aEntrance.tiles[k]
					if tile[1] ~= aTile[1] or tile[2] ~= aTile[2] then
						matching = false
					end
				end
				
				if matching and math.random() < 0.5 then
					for k = 1, #entrance.tiles do
						local tile = entrance.tiles[k]
						placeTile(map, newTile('floor', 'images/tiles/secretWall.png'), tile[1], tile[2])
					end
				end
			end
		end
	end
end

function openSidePassages(map, rooms)
	for i = 1, #rooms do
		local room = rooms[i]
		
		local borderTile = 'floor'
		local borderImage = 'images/tiles/floor.png'
		if #room.entrances > 0 then
			borderTile = room.entrances[1].tile
			borderImage = room.entrances[1].image
		end
		
		for j = 1, #room.border do
			local border = room.border[j]
			if pathPossible(map, border.x, border.y) then
				if math.random() < 0.2 then
					placeTile(map, newTile(borderTile, borderImage), border.x, border.y)
				end
			end
		end
	end
end

function pathPossible(map, x, y)
	for i = -1, 1 do
		for j = -1, 1 do
			if math.abs(i) - math.abs(j) ~= 0 then
				if checkProperties(getTile(map, x + i, y + j), {blocksWalker = false}) then
					if checkProperties(getTile(map, x - i, y - j), {blocksWalker = false}) then
						return true
					end
				end
			end
		end
	end
	return false
end

function markRoomEntrances(map, room)
	for i = 1, #room.entrances do
		local entrance = room.entrances[i]
		for j = 1, #entrance.tiles do
			local tile = entrance.tiles[j]
			placeTile(map, newTile('void', 'images/tiles/void.png'), tile[1], tile[2])
		end
	end
end

function determineTileImages(map)
	for i = map.sX, map.eX do
		for j = map.sY, map.eY do
			
			local centerTile = getTile(map, i, j)
			if centerTile.tileName == 'floor' or centerTile.tileName == 'wall' or centerTile.tileName == 'cornerWall' or centerTile.tileName == 'unFilled' then
				local newImage = centerTile.image
				local adjTiles = {}
				local neighbours = 0
				for x = -1, 1 do
					adjTiles[x] = {}
					for y = -1, 1 do
						adjTiles[x][y] = checkProperties(getTile(map, i + x, j + y), {blocksWalker = true})
						if adjTiles[x][y] then
							neighbours = neighbours + 1
						end
					end
				end
				if centerTile.tileName == 'floor' then
					local tileChoice = math.random()*5
					if tileChoice < 1 then
						newImage = loadTileImage(1, 4, 'images/tiles/mudBrick.png')
					elseif tileChoice < 2 then
						newImage = loadTileImage(1, 6, 'images/tiles/mudBrick.png')
					elseif tileChoice < 3 then
						newImage = loadTileImage(3, 4, 'images/tiles/mudBrick.png')
					elseif tileChoice < 4 then
						newImage = loadTileImage(3, 6, 'images/tiles/mudBrick.png')
					else
						newImage = loadTileImage(5, 2, 'images/tiles/mudBrick.png')
					end
				elseif centerTile.tileName == 'cornerWall' then
					local angle = centerTile.tile.angle
					if angle == 1 then
						if adjTiles[1][-1] then
							newImage = loadTileImage(1, 3, 'images/tiles/mudBrick.png')
						else
							newImage = loadTileImage(4, 3, 'images/tiles/mudBrick.png')
						end
					elseif angle == 2 then
						if adjTiles[1][1] then
							newImage = loadTileImage(1, 1, 'images/tiles/mudBrick.png')
						else
							newImage = loadTileImage(4, 1, 'images/tiles/mudBrick.png')
						end
					elseif angle == 3 then
						if adjTiles[-1][1] then
							newImage = loadTileImage(3, 1, 'images/tiles/mudBrick.png')
						else
							newImage = loadTileImage(6, 1, 'images/tiles/mudBrick.png')
						end
					else
						if adjTiles[-1][-1] then
							newImage = loadTileImage(3, 3, 'images/tiles/mudBrick.png')
						else
							newImage = loadTileImage(6, 3, 'images/tiles/mudBrick.png')
						end
					end
				elseif centerTile.tileName == 'wall' then
					if neighbours == 9 then
						newImage = loadTileImage(2, 2, 'images/tiles/mudBrick.png')
					elseif neighbours == 8 then
						if not adjTiles[1][1] then
							newImage = loadTileImage(4, 4, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][1] then
							newImage = loadTileImage(6, 4, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][-1] then
							newImage = loadTileImage(4, 6, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][-1] then
							newImage = loadTileImage(6, 6, 'images/tiles/mudBrick.png')
						end
					elseif neighbours == 7 then
						if not adjTiles[-1][-1] and not adjTiles[1][1] then
							newImage = loadTileImage(5, 4, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][-1] and not adjTiles[-1][1] then
							newImage = loadTileImage(4, 5, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][1] and not adjTiles[1][1] then
							newImage = loadTileImage(1, 9, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][-1] and not adjTiles[-1][1] then
							newImage = loadTileImage(2, 9, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][-1] and not adjTiles[1][-1] then
							newImage = loadTileImage(3, 9, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][-1] and not adjTiles[1][1] then
							newImage = loadTileImage(4, 9, 'images/tiles/mudBrick.png')
						end
					elseif neighbours == 6 then
						if not adjTiles[0][-1] and not adjTiles[1][-1] then
							newImage = loadTileImage(2, 1, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][-1] and not adjTiles[-1][0] and not adjTiles[-1][1] then
							newImage = loadTileImage(1, 2, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][-1] and not adjTiles[1][0] and not adjTiles[1][1] then
							newImage = loadTileImage(3, 2, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][1] and not adjTiles[0][1] and not adjTiles[1][1] then
							newImage = loadTileImage(2, 3, 'images/tiles/mudBrick.png')
						
						elseif not adjTiles[1][-1] and not adjTiles[-1][-1] and not adjTiles[1][1] then
							newImage = loadTileImage(6, 5, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][-1] and not adjTiles[-1][1] and not adjTiles[1][1] then
							newImage = loadTileImage(5, 6, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][-1] and not adjTiles[1][-1] and not adjTiles[-1][1] then
							newImage = loadTileImage(5, 9, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][1] and not adjTiles[1][-1] and not adjTiles[-1][1] then
							newImage = loadTileImage(6, 9, 'images/tiles/mudBrick.png')
						end
					elseif neighbours == 5 then
						if adjTiles[0][-1] and adjTiles[-1][0] and adjTiles[1][0] and adjTiles[0][1] then
							newImage = loadTileImage(2, 5, 'images/tiles/mudBrick.png')
						end
					elseif neighbours == 1 then
						newImage = loadTileImage(5, 5, 'images/tiles/mudBrick.png')
					end
					
					if newImage == centerTile.image then
						if not adjTiles[-1][0] and not adjTiles[-1][1] and not adjTiles[0][1] and not adjTiles[1][-1] and adjTiles[0][-1] and adjTiles[1][0] then
							newImage = loadTileImage(6, 2, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][0] and not adjTiles[-1][1] and not adjTiles[0][1] and adjTiles[0][-1] and adjTiles[1][0] then
							newImage = loadTileImage(5, 3, 'images/tiles/mudBrick.png')
						
						elseif not adjTiles[0][-1] and not adjTiles[1][-1] and not adjTiles[1][0] and not adjTiles[-1][1] and adjTiles[-1][0] and adjTiles[0][1] then
							newImage = loadTileImage(2, 10, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][-1] and not adjTiles[1][-1] and not adjTiles[1][0] and adjTiles[-1][0] and adjTiles[0][1] then
							newImage = loadTileImage(1, 10, 'images/tiles/mudBrick.png')
						
						elseif not adjTiles[1][0] and not adjTiles[1][1] and not adjTiles[0][1] and not adjTiles[-1][-1] and adjTiles[0][-1] and adjTiles[-1][0] then
							newImage = loadTileImage(4, 10, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][0] and not adjTiles[1][1] and not adjTiles[0][1] and adjTiles[0][-1] and adjTiles[-1][0] then
							newImage = loadTileImage(3, 10, 'images/tiles/mudBrick.png')
							
						elseif not adjTiles[-1][-1] and not adjTiles[0][-1] and not adjTiles[-1][0] and not adjTiles[1][1] and adjTiles[1][0] and adjTiles[0][1] then
							newImage = loadTileImage(6, 10, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][-1] and not adjTiles[0][-1] and not adjTiles[-1][0] and adjTiles[1][0] and adjTiles[0][1] then
							newImage = loadTileImage(5, 10, 'images/tiles/mudBrick.png')
							
						elseif not adjTiles[-1][0] and not adjTiles[1][1] and not adjTiles[1][-1] and adjTiles[1][0] and neighbours >= 4 then
							newImage = loadTileImage(3, 7, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][0] and not adjTiles[1][-1] and adjTiles[1][0] and neighbours >= 4 then
							newImage = loadTileImage(1, 7, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][0] and not adjTiles[1][1] and adjTiles[1][0] and neighbours >= 4 then
							newImage = loadTileImage(2, 7, 'images/tiles/mudBrick.png')
						elseif not adjTiles[-1][0] and adjTiles[1][0] and neighbours >= 4 then
							newImage = loadTileImage(1, 2, 'images/tiles/mudBrick.png')
						
						elseif not adjTiles[1][0] and not adjTiles[-1][1] and not adjTiles[-1][-1] and adjTiles[-1][0] and neighbours >= 4 then
							newImage = loadTileImage(4, 7, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][0] and not adjTiles[-1][-1] and adjTiles[-1][0] and neighbours >= 4 then
							newImage = loadTileImage(5, 7, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][0] and not adjTiles[-1][1] and adjTiles[-1][0] and neighbours >= 4 then
							newImage = loadTileImage(6, 7, 'images/tiles/mudBrick.png')
						elseif not adjTiles[1][0] and adjTiles[-1][0] and neighbours >= 4 then
							newImage = loadTileImage(3, 2, 'images/tiles/mudBrick.png')
						
						elseif not adjTiles[0][1] and not adjTiles[-1][-1] and not adjTiles[1][-1] and adjTiles[0][-1] and neighbours >= 4 then
							newImage = loadTileImage(3, 8, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][1] and not adjTiles[1][-1] and adjTiles[0][-1] and neighbours >= 4 then
							newImage = loadTileImage(2, 8, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][1] and not adjTiles[-1][-1] and adjTiles[0][-1] and neighbours >= 4 then
							newImage = loadTileImage(1, 8, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][1] and adjTiles[0][-1] and neighbours >= 4 then
							newImage = loadTileImage(2, 3, 'images/tiles/mudBrick.png')
							
						elseif not adjTiles[0][-1] and not adjTiles[-1][1] and not adjTiles[1][1] and adjTiles[0][1] and neighbours >= 4 then
							newImage = loadTileImage(6, 8, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][-1] and not adjTiles[1][1] and adjTiles[0][1] and neighbours >= 4 then
							newImage = loadTileImage(5, 8, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][-1] and not adjTiles[-1][1] and adjTiles[0][1] and neighbours >= 4 then
							newImage = loadTileImage(4, 8, 'images/tiles/mudBrick.png')
						elseif not adjTiles[0][-1] and adjTiles[0][1] and neighbours >= 4 then
							newImage = loadTileImage(2, 1, 'images/tiles/mudBrick.png')
						
						elseif adjTiles[-1][0] and adjTiles[1][0] then
							newImage = loadTileImage(5, 1, 'images/tiles/mudBrick.png')
						elseif adjTiles[0][-1] and adjTiles[0][1] then
							newImage = loadTileImage(4, 2, 'images/tiles/mudBrick.png')
						
						elseif adjTiles[0][1] then
							newImage = loadTileImage(2, 4, 'images/tiles/mudBrick.png')
						elseif adjTiles[1][0] then
							newImage = loadTileImage(1, 5, 'images/tiles/mudBrick.png')
						elseif adjTiles[-1][0] then
							newImage = loadTileImage(3, 5, 'images/tiles/mudBrick.png')
						elseif adjTiles[0][-1] then
							newImage = loadTileImage(2, 6, 'images/tiles/mudBrick.png')
						end
					end
				end
				centerTile.image = newImage
			end
		end
	end
end

function drawRoomConnections(rooms, xOffset, yOffset, tileW, tileH)
	for i = 1, #rooms do
		local room = rooms[i]
		local drawX = math.ceil(room.x*tileW + xOffset)
		local drawY = math.ceil(room.y*tileH + yOffset)
		love.graphics.setColor(1, 0, 0, 0.5)
		love.graphics.circle('fill', drawX, drawY, 3)
		love.graphics.print(room.distance, drawX + 10, drawY + 10)
		for j = 1, #room.adjacent do
			local aRoom = room.adjacent[j]
			local lineX = math.ceil(aRoom.x*tileW + xOffset)
			local lineY = math.ceil(aRoom.y*tileH + yOffset)
			love.graphics.line(drawX, drawY, lineX, lineY)
		end
	end
end