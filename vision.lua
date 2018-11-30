function innitiateVisionMap(map)
	local visionMap = {sX = map.sX, sY = map.sY, eX = map.eX, eY = map.eY, tiles = {}}
	for x = map.sX, map.eX do
		visionMap.tiles[x] = {}
		for y = map.sY, map.eY do
			visionMap.tiles[x][y] = -1
		end
	end
	return visionMap
end

function updateVisionMap(visionMap, seenTiles)
	for i = 1, #seenTiles do
		visionMap.tiles[seenTiles[i][1]][seenTiles[i][2]] = 2
	end
	
	for x = visionMap.sX, visionMap.eX do
		for y = visionMap.sY, visionMap.eY do
			if visionMap.tiles[x][y] == 2 then
				visionMap.tiles[x][y] = 1
			elseif visionMap.tiles[x][y] == 1 then
				visionMap.tiles[x][y] = 0
			end
		end
	end
end

function revealVisionMap(visionMap)
	for x = visionMap.sX, visionMap.eX do
		for y = visionMap.sY, visionMap.eY do
			visionMap.tiles[x][y] = 'infinite'
		end
	end
end

function getVisionTile(visionMap, x, y)
	if x >= visionMap.sX and x <= visionMap.eX and y >= visionMap.sY and y <= visionMap.eY then
		local value = visionMap.tiles[x][y]
		if value == 'infinite' then
			value = 1
		end
		return value
	else
		return -1
	end
end

function seeTile(map, seenList, tilesSeen, x, y, xCenter, yCenter, endBeam)
	local repeated = false
	if tilesSeen[x] then
		if tilesSeen[x][y] then
			repeated = true
		end
	end
	
	if not repeated then
		table.insert(seenList, {x + xCenter, y + yCenter})
	end
	
	if not endBeam then
		tilesSeen[x][y] = true
		
		for o = -1, 1 do
			if o ~= 0 then
				if checkProperties(getTile(map, xCenter + x + o, yCenter + y), {blocksLight = true}) then
					seeTile(map, seenList, tilesSeen, x + o, y, xCenter, yCenter, true)
				end
				if checkProperties(getTile(map, xCenter + x, yCenter + y + o), {blocksLight = true}) then
					seeTile(map, seenList, tilesSeen, x, y + o, xCenter, yCenter, true)
				end
			end
		end
	end
end

function seeTiles(map, xCenter, yCenter, radius)
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
	
	local tilesSeen = {}
	local seenList = {}
	for x = -radius, radius do
		tilesSeen[x] = {}
		for y = -radius, radius do
			tilesSeen[x][y] = false
		end
	end
	seeTile(map, seenList, tilesSeen, 0, 0, xCenter, yCenter, false)
	
	for r = 1, radius do
		for n = 1, 8*r do
			local x, y = determineTile(n, r)
			local angleToCenter = math.atan2(-y, -x)
			local xOff, yOff = findTileAtAngle(angleToCenter)
			if tilesSeen[x + xOff][y + yOff] then
				if checkProperties(getTile(map, xCenter + x, yCenter + y), {blocksLight = false}) then
					seeTile(map, seenList, tilesSeen, x, y, xCenter, yCenter, false)
				else
					seeTile(map, seenList, tilesSeen, x, y, xCenter, yCenter, true)
				end
			end
		end
	end
	return seenList
end

function drawShadows(visionMap, xOffset, yOffset, tileW, tileH)
	local mapXCenter = math.ceil(-(xOffset - love.graphics.getWidth()/2)/tileW)
	local mapYCenter = math.ceil(-(yOffset - love.graphics.getHeight()/2)/tileH)
	
	local sX = mapXCenter - math.ceil(love.graphics.getWidth()/(2*tileW))
	local eX = mapXCenter + math.ceil(love.graphics.getWidth()/(2*tileW))
	local sY = mapYCenter - math.ceil(love.graphics.getHeight()/(2*tileH))
	local eY = mapYCenter + math.ceil(love.graphics.getHeight()/(2*tileH))
	
	love.graphics.setColor(1, 1, 1, 1)
	for i = sX, eX do
		for j = sY, eY do
			if getVisionTile(visionMap, i, j) >= 0 then
				local adjTiles = {}
				local neighbours = 0
				for x = -1, 1 do
					adjTiles[x] = {}
					for y = -1, 1 do
						adjTiles[x][y] = false
						if getVisionTile(visionMap, i + x, j + y) == -1 then
							adjTiles[x][y] = true
						end
					end
				end
				
				local cornersBlocked = {false, false, false, false}
				if adjTiles[-1][0] and adjTiles[1][0] and adjTiles[0][1] and adjTiles[0][-1] then
					drawImageOnTile(loadImage('images/shadows/full.png'), i, j, 0, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, true, true}
					
				elseif adjTiles[-1][0] and adjTiles[0][1] and adjTiles[0][-1] then
					drawImageOnTile(loadImage('images/shadows/U.png'), i, j, 0, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, true, true}
				elseif adjTiles[1][0] and adjTiles[0][1] and adjTiles[0][-1] then
					drawImageOnTile(loadImage('images/shadows/U.png'), i, j, math.pi, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, true, true}
				elseif adjTiles[1][0] and adjTiles[-1][0] and adjTiles[0][-1] then
					drawImageOnTile(loadImage('images/shadows/U.png'), i, j, math.pi/2, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, true, true}
				elseif adjTiles[1][0] and adjTiles[-1][0] and adjTiles[0][1] then
					drawImageOnTile(loadImage('images/shadows/U.png'), i, j, -math.pi/2, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, true, true}
				
				elseif adjTiles[-1][0] and adjTiles[0][-1] then
					drawImageOnTile(loadImage('images/shadows/L.png'), i, j, 0, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, false, true}
				elseif adjTiles[-1][0] and adjTiles[0][1] then
					drawImageOnTile(loadImage('images/shadows/L.png'), i, j, -math.pi/2, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, false, true, true}
				elseif adjTiles[1][0] and adjTiles[0][-1] then
					drawImageOnTile(loadImage('images/shadows/L.png'), i, j, math.pi/2, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {true, true, true, false}
				elseif adjTiles[1][0] and adjTiles[0][1] then
					drawImageOnTile(loadImage('images/shadows/L.png'), i, j, math.pi, xOffset, yOffset, tileW, tileH)
					cornersBlocked = {false, true, true, true}
				
				else
					if adjTiles[-1][0] then
						drawImageOnTile(loadImage('images/shadows/line.png'), i, j, 0, xOffset, yOffset, tileW, tileH)
						cornersBlocked[1] = true
						cornersBlocked[4] = true
					end
					if adjTiles[1][0] then
						drawImageOnTile(loadImage('images/shadows/line.png'), i, j, math.pi, xOffset, yOffset, tileW, tileH)
						cornersBlocked[2] = true
						cornersBlocked[3] = true
					end
					if adjTiles[0][-1] then
						drawImageOnTile(loadImage('images/shadows/line.png'), i, j, math.pi/2, xOffset, yOffset, tileW, tileH)
						cornersBlocked[1] = true
						cornersBlocked[2] = true
					end
					if adjTiles[0][1] then
						drawImageOnTile(loadImage('images/shadows/line.png'), i, j, -math.pi/2, xOffset, yOffset, tileW, tileH)
						cornersBlocked[3] = true
						cornersBlocked[4] = true
					end
				end
				
				if not cornersBlocked[1] then
					if adjTiles[-1][-1] then
						drawImageOnTile(loadImage('images/shadows/corner.png'), i, j, 0, xOffset, yOffset, tileW, tileH)
					end
				end
				if not cornersBlocked[2] then
					if adjTiles[1][-1] then
						drawImageOnTile(loadImage('images/shadows/corner.png'), i, j, math.pi/2, xOffset, yOffset, tileW, tileH)
					end
				end
				if not cornersBlocked[3] then
					if adjTiles[1][1] then
						drawImageOnTile(loadImage('images/shadows/corner.png'), i, j, math.pi, xOffset, yOffset, tileW, tileH)
					end
				end
				if not cornersBlocked[4] then
					if adjTiles[-1][1] then
						drawImageOnTile(loadImage('images/shadows/corner.png'), i, j, -math.pi/2, xOffset, yOffset, tileW, tileH)
					end
				end
			end
		end
	end
end