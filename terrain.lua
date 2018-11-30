local tileLibrary = {}
tileLibrary['void'] = {blocksWalker = true, blocksLight = true, blocksThought = true, destroysThought = true}

tileLibrary['unFilled'] = {blocksWalker = true, blocksLight = true, blocksThought = true, bouncesThought = true}
tileLibrary['floor'] = {blocksWalker = false, blocksLight = false, constructed = true}
tileLibrary['wall'] = {blocksWalker = true, blocksLight = true, blocksThought = true, bouncesThought = true, constructed = true}
tileLibrary['cornerWall'] = {blocksWalker = true, blocksLight = true, blocksThought = true, bouncesThought = true, constructed = true, angle = 0, duplicate = true}
tileLibrary['secretWall'] = {blocksLight = true, blocksThought = true, bouncesThought = true, constructed = true}

function newMap(initialX, initialY, baseTile, baseImage)
	local startX = -math.floor(initialX/2)
	local startY = -math.floor(initialY/2)
	local map = {tiles = {}, parentWorld = nil, sX = startX, sY = startY, eX = startX + initialX - 1, eY = startY + initialY - 1, baseTile = baseTile, baseImage = baseImage}
	
	fillEmptyMapSpace(map)
	return map
end

function fillEmptyMapSpace(map)
	for i = map.sX, map.eX do
		if map.tiles[i] == nil then
			map.tiles[i] = {}
		end
		for j = map.sY, map.eY do
			if map.tiles[i][j] == nil then
				placeTile(map, newTile(map.baseTile, map.baseImage), i, j)
			end
		end
	end
end

function newTile(baseTile, baseImage)
	local tileName = baseTile
	baseTile = tileLibrary[baseTile]
	if baseTile.duplicate then
		local duplicateTile = {}
		for key, value in pairs(baseTile) do
			duplicateTile[key] = value
		end
		baseTile = duplicateTile
	end
	
	return {x = 0, y = 0, tile = baseTile, tileName = tileName, image = loadImage(baseImage), actor = nil, thought = nil, book = nil}
end

function setTileProperties(tile, properties)
	tile = tile.tile
	if tile.duplicate == nil then
		local duplicateTile = {}
		for key, value in pairs(tile) do
			duplicateTile[key] = value
		end
		tile = duplicateTile
		tile.duplicate = true
	end
	
	for key, value in pairs(properties) do
		tile[key] = value
	end
	return tile
end

function checkProperties(tile, properties)
	if tile then
		for key, value in pairs(properties) do
			if tile.tile[key] then
				if tile.tile[key] ~= value then
					return false
				end
			else
				if value then
					return false
				end
			end
		end
		return true
	else
		return false
	end
end

function placeTile(map, tile, x, y)
	local changed = false
	if x < map.sX then
		map.sX = x
		changed = true
	elseif x > map.eX then
		map.eX = x
		changed = true
	end
	if y < map.sY then
		map.sY = y
		changed = true
	elseif y > map.eY then
		map.eY = y
		changed = true
	end
	if changed then
		fillEmptyMapSpace(map)
	end
	map.tiles[x][y] = tile
	tile.x = x
	tile.y = y
	
	return tile
end

function getTile(map, x, y)
	if x then
		if checkInsideMap(map, x, y) then
			return map.tiles[x][y]
		else
			return newTile('void', 'images/tiles/void.png')
		end
	else
		return false
	end
end

function checkInsideMap(map, x, y)
	if x >= map.sX and x <= map.eX and y >= map.sY and y <= map.eY then
		return true
	else
		return false
	end
end

function checkTilesIdentical(tile1, tile2)
	local sharedProperties = {}
	local n = 0
	for key, value in pairs(tile1.tile) do
		sharedProperties[key] = value
		n = n + 1
	end
	for key, value in pairs(tile2.tile) do
		if sharedProperties[key] ~= nil then
			if sharedProperties[key] == value then
				n = n - 1
			else
				n = -1
				break
			end
		else
			n = -1
			break
		end
	end
	
	if n == 0 then
		return true
	else
		return false
	end
end

function drawMap(map, visionMap, xOffset, yOffset, tileW, tileH)
	local mapXCenter = math.ceil(-(xOffset - love.graphics.getWidth()/2)/tileW)
	local mapYCenter = math.ceil(-(yOffset - love.graphics.getHeight()/2)/tileH)
	
	local sX = mapXCenter - math.ceil(love.graphics.getWidth()/(2*tileW))
	local eX = mapXCenter + math.ceil(love.graphics.getWidth()/(2*tileW))
	local sY = mapYCenter - math.ceil(love.graphics.getHeight()/(2*tileH))
	local eY = mapYCenter + math.ceil(love.graphics.getHeight()/(2*tileH))
	
	for i = sX, eX do
		for j = sY, eY do
			if checkInsideMap(map, i, j) then
				if getVisionTile(visionMap, i, j) >= 0 then
					drawTile(map.tiles[i][j], xOffset, yOffset, tileW, tileH)
					if getVisionTile(visionMap, i, j) == 0 then
						love.graphics.setColor(0, 0, 0, 0.5)
						love.graphics.rectangle('fill', math.ceil(tileW*i + xOffset) - tileW/2, math.ceil(tileH*j + yOffset) - tileH/2, tileW, tileH)
					elseif getVisionTile(visionMap, i, j) == -1 then
						love.graphics.setColor(0, 0, 0, 0.8)
						love.graphics.rectangle('fill', math.ceil(tileW*i + xOffset - tileW/2), math.ceil(tileH*j + yOffset - tileH/2), tileW, tileH)
					end
				end
			end
		end
	end
end

function drawTile(tile, xOffset, yOffset, tileW, tileH)
	local drawX = math.ceil(tile.x*tileW + xOffset)
	local drawY = math.ceil(tile.y*tileH + yOffset)
	local sX = tileW/tile.image.width
	local sY = tileH/tile.image.height
	
	local angle = 0
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(tile.image.image, drawX, drawY, angle, sX, sY, tile.image.width/2, tile.image.height/2)
	
	if tile.book then
		if checkBookOwnedByPlayer(Player, tile.book.argument.name) then
			love.graphics.setColor(0.5, 0.5, 0.5, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		drawImageOnTile(loadImage(tile.book.argument.image), tile.x, tile.y, 0, xOffset, yOffset, tileW, tileH)
		
		activateTutorial('grabbing', tile)
	end
	
	if debugSettings.showThoughtTiles then
		if tile.thought then
			love.graphics.setColor(1, 0, 1, 1)
			love.graphics.circle('fill', drawX, drawY, 25)
		end
	end
end

function drawImageOnTile(image, x, y, angle, xOffset, yOffset, tileW, tileH)
	local drawX = math.ceil(x*tileW + xOffset)
	local drawY = math.ceil(y*tileH + yOffset)
	local sX = tileW/image.width
	local sY = tileH/image.height
	
	love.graphics.draw(image.image, drawX, drawY, angle, sX, sY, image.width/2, image.height/2)
end