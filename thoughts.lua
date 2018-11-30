function newThought(world, thinker, x, y, direction, speed, power, properties)
	local thought = {thinker = thinker, x = x, y = y, direction = direction, speed = speed, movesLeft = 0, power = power, summoningSick = true, parentMap = nil, lastThought = nil}
	
	if properties then
		for key, value in pairs(properties) do
			thought[key] = value
			if key == 'orbit' or key == 'anchor' then
				table.insert(thinker.orbitingThoughts, thought)
			end
		end
	end
	
	if thinker ~= Player.actor then
		thought.hostile = true
	end
	
	local tile = getTile(world.map, x, y)
	if tile.actor == nil then
		if placeThought(world.map, thought, x, y) then
			table.insert(world.thoughts, thought)
			
			if getVisionTile(world.visionMap, thinker.x, thinker.y) == 1 and world == World then
				thoughtCastLine(thought, thinker, 10)
			end
		else
			thought.dead = true
		end
	else
		thought.dead = true
	end
end

function checkThoughtFits(map, x, y)
	return checkProperties(getTile(map, x, y), {blocksThought = false})
end

function placeThought(map, thought, x, y)
	local tile = getTile(map, x, y)
	if checkThoughtFits(map, x, y) then
		if getTile(map, thought.x, thought.y).thought == thought then
			getTile(map, thought.x, thought.y).thought = nil
		end
		getTile(map, x, y).thought = thought
		thought.x = x
		thought.y = y
		thought.parentMap = map
		if getVisionTile(World.visionMap, thought.x, thought.y) == 1 then
			createThoughtTrail(thought, 10)
		end
		return true
	end
	return false
end

function updateThoughts(world)
	world.lastTurnThoughts = {}
	local thoughts = world.thoughts
	for i = 1, #thoughts do
		local thought = thoughts[i]
		thought.movesLeft = thought.speed
		
		local lastThought = {}
		for key, value in pairs(thought) do
			lastThought[key] = value
		end
		lastThought.currentThought = thought
		thought.lastThought = lastThought
		table.insert(world.lastTurnThoughts, lastThought)
	end
	checkThoughtCollisions(thoughts)
	
	local continueMoving = true
	while continueMoving do
		continueMoving = moveThoughts(thoughts)
		checkActorThoughtCollisions(world.actors, world.map, thoughts)
		checkThoughtCollisions(thoughts)
	end
	
	for i = 1, #thoughts do
		local thought = thoughts[i]
		if thought.homing then
			homeThought(thought)
		end
		if not thought.dead then
			local tile = getTile(world.map, thought.x, thought.y)
			tile.thought = thought
		end
		thought.summoningSick = false
	end
	checkActorThoughtCollisions(world.actors, world.map, thoughts)
end

function moveThoughts(thoughts)
	local movesLeft = false
	local crossCollisions = {}
	for i = 1, #thoughts do
		local thought = thoughts[i]
		if not thought.summoningSick and thought.movesLeft > 0 then
			thought.movesLeft = thought.movesLeft - 1
			if thought.orbit then
				orbitThought(thought)
			end
			local dirX, dirY = findTileAtAngle(thought.direction)
			moveThought(thought, dirX, dirY, crossCollisions)
			if thought.movesLeft > 0 then
				movesLeft = true
			end
		end
	end
	
	for i = 1, #crossCollisions do
		local cCollision = crossCollisions[i]
		local thought = cCollision.thought
		if thought.x == cCollision.lastX and thought.y == cCollision.lastY then
			local winningThought = collideThoughts(thought, cCollision.lastThought)
			if winningThought ~= thought then
				thought.dead = true
			end
			if winningThought ~= cCollision.lastThought then
				cCollision.lastThought.dead = true
			end
		end
	end
	
	return movesLeft
end

function moveThought(thought, dirX, dirY, crossCollisions)
	local dX = thought.x + dirX
	local dY = thought.y + dirY
	
	local targetTile = getTile(thought.parentMap, dX, dY)
	if checkThoughtFits(thought.parentMap, dX, dY) then
		if targetTile.thought and targetTile.thought ~= thought then
			table.insert(crossCollisions, {lastX = thought.x, lastY = thought.y, thought = targetTile.thought, lastThought = thought})
		end
		
		placeThought(thought.parentMap, thought, dX, dY)
	elseif checkProperties(targetTile, {bouncesThought = true}) then
		dX, dY = bounceThought(thought, targetTile)
		targetTile = getTile(thought.parentMap, dX, dY)
		if targetTile.thought and targetTile.thought ~= thought then
			table.insert(crossCollisions, {lastX = thought.x, lastY = thought.y, thought = targetTile.thought, lastThought = thought})
		end
		
		placeThought(thought.parentMap, thought, dX, dY)
	else
		thought.movesLeft = 0
	end
end

function homeThought(thought)
	local directionToPlayer = math.atan2(Player.actor.y - thought.y, Player.actor.x - thought.x)
	local dirX, dirY = findTileAtAngle(directionToPlayer)
	thought.direction = math.atan2(dirY, dirX)
end

function orbitThought(thought)
	local dirX, dirY = findTileAtAngle(thought.direction)
	local dX = thought.x + dirX
	local dY = thought.y + dirY
	
	local distance = findCartesianDistance(dX, dY, thought.orbit.actor.x, thought.orbit.actor.y)
	if distance > thought.orbit.distance then
		thought.direction = thought.direction + thought.orbit.direction*math.pi/2
		if distance > thought.orbit.distance + 1 then
			thought.orbit = nil
		end
	end
end

function bounceThought(thought, tile)
	local bX = 0
	local bY = 0
	local displace = false
	local displaceX = 0
	local displaceY = 0
	local mX, mY = findTileAtAngle(thought.direction)
	if checkProperties(tile, {angle = 0}) then
		bX = 1
		bY = 1
		displace = true
	elseif checkProperties(tile, {angle = 1}) then
		bX = -1
		bY = 1
		displace = true
	elseif checkProperties(tile, {angle = 2}) then
		bX = -1
		bY = -1
		displace = true
	elseif checkProperties(tile, {angle = 3}) then
		bX = 1
		bY = -1
		displace = true
	else
		bX = -mX
		bY = -mY
		if math.abs(bX) + math.abs(bY) == 2 then
			bX = 0
			bY = 0
			if checkProperties(getTile(thought.parentMap, thought.x + mX, thought.y), {bouncesThought = true}) then
				bX = -2*mX
				displaceX = -mX
			end
			if checkProperties(getTile(thought.parentMap, thought.x, thought.y + mY), {bouncesThought = true}) then
				bY = -2*mY
				displaceY = -mY
			end
			if bX == 0 and bY == 0 then
				bX = -mX
				bY = -mY
			end
		end
	end
	
	mX = mX + bX
	mY = mY + bY
	if mX == 0 and mY == 0 then
		mX = mX + bX
		mY = mY + bY
	end
	
	if mX > 1 then
		mX = 1
	elseif mX < -1 then
		mX = -1
	end
	if mY > 1 then
		mY = 1
	elseif mY < -1 then
		mY = -1
	end
	
	local dX = thought.x
	local dY = thought.y
	if displace then
		displaceX = mX
		displaceY = mY
	end
	
	thought.direction = math.atan2(mY, mX)
	return tile.x + displaceX, tile.y + displaceY
end

function checkThoughtCollisions(thoughts)
	local i = 1
	while i <= #thoughts do
		local thought = thoughts[i]
		local mapTile = getTile(thought.parentMap, thought.x, thought.y)
		
		if mapTile.thought ~= thought and not thought.dead then
			for j = 1, #thoughts do
				local cThought = thoughts[j]
				if i ~= j then
					if thought.x == cThought.x and thought.y == cThought.y then
						mapTile.thought = collideThoughts(thought, cThought)
					end
					if thought.dead then
						break
					end
				end
			end
		end
		i = i + 1
	end
	clearOutDeadThoughts(thoughts)
end

function clearOutDeadThoughts(thoughts)
	local i = 1
	while i <= #thoughts do
		local thought = thoughts[i]
		if thought.dead then
			removeThought(thoughts, i)
		else
			i = i + 1
		end
	end
end

function removeThought(thoughts, i)
	local thought = thoughts[i]
	thought.dead = true
	table.remove(thoughts, i)
	getTile(thought.parentMap, thought.x, thought.y).thought = nil
end

function clearThoughts(map, x, y, radius)
	local viableTiles = seeTiles(map, x, y, radius)
	for i = 1, #viableTiles do
		local x = viableTiles[i][1]
		local y = viableTiles[i][2]
		local tile = getTile(map, x, y)
		if tile.thought then
			tile.thought.dead = true
		end
		newParticle(x, y, true, 0, 0, {kind = 'rect', xSize = 44, ySize = 44}, {1, 1, 1, 0.5}, 1.5, 0)
	end
end

function collideThoughts(thought1, thought2)
	local dX2, dY2 = findTileAtAngle(thought2.direction)
	dX2 = thought2.speed*dX2
	dY2 = thought2.speed*dY2
	local dX1, dY1 = findTileAtAngle(thought1.direction)
	dX1 = thought1.speed*dX1
	dY1 = thought1.speed*dY1
	if (thought1.push or thought2.push) and not thought1.dead and not thought2.dead then
		local newDX = dX2 + dX1
		local newDY = dY2 + dY1
		if not (determineDiagonal(math.atan2(newDY, newDX)) or newDX == 0 or newDY == 0) then
			if math.abs(newDX) < math.abs(newDY) then
				newDY = math.abs(newDX)*(newDY/math.abs(newDY))
			else
				newDX = math.abs(newDY)*(newDX/math.abs(newDX))
			end
		end
		
		local newAngle = math.atan2(newDY, newDX)
		local newSpeed = math.max(math.abs(newDX), math.abs(newDY))
		if newSpeed > 4 then
			newSpeed = 4
		end
		if thought1.push then
			if not thought1.hostile then
				thought2.hostile = false
			end
			thought2.movesLeft = thought2.movesLeft + (newSpeed - thought2.speed)
			thought2.speed = newSpeed
			thought2.direction = newAngle
		elseif thought2.push then
			if not thought2.hostile then
				thought1.hostile = false
			end
			thought1.movesLeft = thought1.movesLeft + (newSpeed - thought1.speed)
			thought1.speed = newSpeed
			thought1.direction = newAngle
		end
	end
	
	local winningThought = 0
	if thought2.power < thought1.power then
		winningThought = thought1
		thought2.dead = true
	elseif thought1.power < thought2.power then
		winningThought = thought2
		thought1.dead = true
	elseif thought1.power == thought2.power then
		winningThought = nil
		thought1.dead = true
		thought2.dead = true
	end
	
	if thought1.dead and getVisionTile(World.visionMap, thought1.x, thought1.y) == 1 then
		fragmentThought(thought1, 10)
	end
	if thought2.dead and getVisionTile(World.visionMap, thought2.x, thought2.y) == 1 then
		fragmentThought(thought2, 10)
	end
	
	local tmp = thought1.power
	thought1.power = thought1.power - thought2.power
	thought2.power = thought2.power - tmp
	if thought1.power < 0 then
		thought1.power = 0
	end
	if thought2.power < 0 then
		thought2.power = 0
	end
	
	return winningThought
end

function createThoughtTrail(thought, n)
	if thought.lastThought and thought.speed > 0 then
		local previousX = thought.lastThought.x
		local previousY = thought.lastThought.y
		local trailDirection = math.atan2(thought.y - previousY, thought.x - previousX)
		local trailDistance = math.sqrt((thought.y - previousY)^2 + (thought.x - previousX)^2)
		for i = 1, n do
			local dist = (i - 1)*(trailDistance/n)
			local posX = previousX + dist*math.cos(trailDirection)
			local posY = previousY + dist*math.sin(trailDirection)
			
			local arrowImage, baseImage, angle, colour = determineThoughtImage(thought)
			colour[4] = 0.4*(i*(1/n))
			if baseImage then
				newParticle(posX, posY, true, 0, 0, {kind = 'image', image = baseImage, angle = 0, sX = 1, sY = 1}, colour, 2, 0)
			end
			if arrowImage then
				newParticle(posX, posY, true, 0, 0, {kind = 'image', image = arrowImage, angle = angle, sX = 1, sY = 1}, colour, 2, 0)
			end
		end
	end
end

function fragmentThought(thought, n)
	for i = 1, n do
		local posX = thought.x + plusOrMinus()*math.random()*0.3
		local posY = thought.y + plusOrMinus()*math.random()*0.3
		
		local direction = thought.direction + plusOrMinus()*math.random()*0.5
		local speedMultiple = 3
		local arrowImage, baseImage, angle, colour = determineThoughtImage(thought)
		colour[4] = 0.5
		newParticle(posX, posY, true, direction, speedMultiple*thought.speed, {kind = 'rect', xSize = 3, ySize = 3}, colour, 1, 0, {accelerate = -speedMultiple*thought.speed})
	end
end

function thoughtCastLine(thought, thinker, n)
	local trailDirection = math.atan2(thought.y - thinker.y, thought.x - thinker.x)
	local trailDistance = math.sqrt((thought.y - thinker.y)^2 + (thought.x - thinker.x)^2)
	for i = 1, n do
		local dist = (i - 1)*(trailDistance/n)
		local posX = thinker.x + dist*math.cos(trailDirection)
		local posY = thinker.y + dist*math.sin(trailDirection)
		
		local speed = 0.1
		local direction = math.random()*2*math.pi
		
		local arrowImage, baseImage, angle, colour = determineThoughtImage(thought)
		colour[4] = 0.8
		newParticle(posX, posY, true, direction, speed, {kind = 'circle', radius = 2}, colour, 1, 0)
	end
end

function determineThoughtImage(thought)
	local mX, mY = findTileAtAngle(thought.direction)
	local arrow = nil
	local base = nil
	local angle = 0
	if thought.orbit or thought.anchor then
		base = loadImage('images/thoughts/orbiting.png')
	elseif thought.homing then
		base = loadImage('images/thoughts/homing.png')
	elseif thought.power > 0 then
		base = loadImage('images/thoughts/normal.png')
	end
	
	local imageAdditive = ''
	if thought.hostile then
		imageAdditive = 'Enemy'
	end
	
	if math.abs(mX) + math.abs(mY) == 1 then
		if thought.speed == 1 then
			arrow = loadImage('images/thoughts/straightSlow' .. imageAdditive .. '.png')
		elseif thought.speed == 2 then
			arrow = loadImage('images/thoughts/straightMedium' .. imageAdditive .. '.png')
		elseif thought.speed == 3 then
			arrow = loadImage('images/thoughts/straightFast' .. imageAdditive .. '.png')
		elseif thought.speed == 4 then
			arrow = loadImage('images/thoughts/straightVeryFast' .. imageAdditive .. '.png')
		end
		if mX == -1 then
			angle = math.pi
		elseif mY == 1 then
			angle = math.pi/2
		elseif mY == -1 then
			angle = -math.pi/2
		end
	elseif determineDiagonal(thought.direction) then
		if thought.speed == 1 then
			arrow = loadImage('images/thoughts/diagonalSlow' .. imageAdditive .. '.png')
		elseif thought.speed == 2 then
			arrow = loadImage('images/thoughts/diagonalMedium' .. imageAdditive .. '.png')
		elseif thought.speed == 3 then
			arrow = loadImage('images/thoughts/diagonalFast' .. imageAdditive .. '.png')
		elseif thought.speed == 4 then
			arrow = loadImage('images/thoughts/diagonalVeryFast' .. imageAdditive .. '.png')
		end
		if mX == 1 and mY == 1 then
			angle = math.pi/2
		elseif mX == -1 and mY == 1 then
			angle = math.pi
		elseif mX == -1 and mY == -1 then
			angle = -math.pi/2
		end
	end
	
	local colour = {1, 1, 1, 1}
	if thought.power == 1 then
		colour = {1, 0, 0, 1}
	elseif thought.power == 2 then
		colour = {0, 1, 0, 1}
	elseif thought.power == 3 then
		colour = {0, 1, 1, 1}
	end
	return arrow, base, angle, colour
end

function drawThought(thought, xOffset, yOffset, tileW, tileH, lastTurn)
	local imageArrow, imageBase, angle, colour = determineThoughtImage(thought)
	
	local drawX = math.ceil(thought.x*tileW + xOffset)
	local drawY = math.ceil(thought.y*tileH + yOffset)
	
	if lastTurn then
		colour[4] = 0.5
		local currentDX = math.ceil(thought.currentThought.x*tileW + xOffset)
		local currentDY = math.ceil(thought.currentThought.y*tileH + yOffset)
		love.graphics.setColor(colour)
		love.graphics.setLineWidth(2)
		love.graphics.line(drawX, drawY, currentDX, currentDY)
	end
	love.graphics.setColor(colour)
	if imageBase then
		local sX = tileW/imageBase.width
		local sY = tileH/imageBase.height
		love.graphics.draw(imageBase.image, drawX, drawY, angle, sX, sY, math.ceil(imageBase.width/2), math.ceil(imageBase.height/2))
	end
	if imageArrow then
		local sX = tileW/imageArrow.width
		local sY = tileH/imageArrow.height
		love.graphics.draw(imageArrow.image, drawX, drawY, angle, sX, sY, math.ceil(imageArrow.width/2), math.ceil(imageArrow.height/2))
	end
end

function drawThoughts(thoughts, visionMap, xOffset, yOffset, tileW, tileH, lastTurn)
	for i = 1, #thoughts do
		local thought = thoughts[i]
		if getVisionTile(visionMap, thought.x, thought.y) == 1 then
			drawThought(thought, xOffset, yOffset, tileW, tileH, lastTurn)
		end
	end
end