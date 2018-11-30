function drawBorderedBacking(x, y, width, height)
	love.graphics.setColor(0, 0, 0, 0.4)
	love.graphics.rectangle('fill', x, y, width, height)
	love.graphics.setColor(1, 1, 1, 0.4)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle('line', x, y, width, height)
end

function drawInWorldInterface(world, player, xOffset, yOffset, tileW, tileH)
	love.graphics.setColor(1, 1, 1, 1)
	if player.targeting then
		drawImageOnTile(loadImage('images/interface/cursor.png'), player.targetX, player.targetY, 0, xOffset, yOffset, tileW, tileH)
		
		if player.targeting == 'argument' then
			local range = player.targetingArgument.targets[#player.targets + 1].range
			local centerX = player.actor.x
			local centerY = player.actor.y
			if player.targetingArgument.targets[#player.targets + 1].origin == 'last' then
				centerX = player.targets[#player.targets][1]
				centerY = player.targets[#player.targets][2]
			end
			
			local drawX = math.ceil((centerX - range - 0.5)*tileW + xOffset)
			local drawY = math.ceil((centerY - range - 0.5)*tileH + yOffset)
			local width = (2*range + 1)*tileW
			local height = (2*range + 1)*tileH
			
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.setLineWidth(3)
			love.graphics.rectangle('line', drawX, drawY, width, height)
			
			drawTargetingIndicators(player.targetingArgument, player.actor, player.targets, xOffset, yOffset, tileW, tileH)
		end
	end
end

function drawTargetingIndicators(argument, actor, targets, xOffset, yOffset, tileW, tileH)
	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #targets do
		local target = targets[i]
		local argumentTarget = argument.targets[i]
		local lastTarget = targets[i - 1]
		if argumentTarget.aimType == 'place' then
			drawImageOnTile(loadImage('images/interface/point.png'), target[1], target[2], 0, xOffset, yOffset, tileW, tileH)
		else
			local angle = 0
			if argumentTarget.origin == 'actor' then
				angle = math.atan2(target[2] - actor.y, target[1] - actor.x)
			elseif argumentTarget.origin == 'last' then
				angle = math.atan2(target[2] - lastTarget[2], target[1] - lastTarget[1])
			end
			
			if determineDiagonal(angle) then
				angle = angle + math.pi/4
				drawImageOnTile(loadImage('images/interface/directionDiagonal.png'), target[1], target[2], angle, xOffset, yOffset, tileW, tileH)
			else
				drawImageOnTile(loadImage('images/interface/directionStraight.png'), target[1], target[2], angle, xOffset, yOffset, tileW, tileH)
			end
		end
	end
end

function drawEnergyBar(player, drawX, drawY, width)
	local height = 22
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle('fill', drawX - 4, drawY - 4, width + 8, height + 8)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	love.graphics.rectangle('fill', drawX, drawY, width, height)
	love.graphics.setColor(0.6, 0.6, 0.6, 1)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle('line', drawX, drawY, width, height)
	
	love.graphics.setLineWidth(2)
	local cellWidth = (width - 4)/player.maxEnergy
	for i = 1, player.maxEnergy do
		local cellX = drawX + (player.maxEnergy - i)*cellWidth + 2
		local cellY = drawY + 2
		if player.maxEnergy - i + 1 <= player.energy then
			love.graphics.setColor(1, 1, 0, 1)
			love.graphics.rectangle('fill', cellX, cellY, cellWidth, height - 4)
			love.graphics.setColor(0.5, 0.5, 0, 1)
			love.graphics.rectangle('line', cellX, cellY, cellWidth, height - 4)
		else
			love.graphics.setColor(0.1, 0.1, 0.1, 1)
			love.graphics.rectangle('line', cellX, cellY, cellWidth, height - 4)
		end
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print('Energy', drawX, drawY - 20)
end

function drawHealthBar(player, drawX, drawY, width)
	local height = 42
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle('fill', drawX - 4, drawY - 4, width + 8, height + 8)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	love.graphics.rectangle('fill', drawX, drawY, width, height)
	love.graphics.setColor(0.6, 0.6, 0.6, 1)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle('line', drawX, drawY, width, height)
	
	love.graphics.setLineWidth(2)
	local cellWidth = (width - 4)/player.maxHealth
	for i = 1, player.maxHealth do
		local cellX = drawX + (player.maxHealth - i)*cellWidth + 2
		local cellY = drawY + 2
		if player.maxHealth - i + 1 <= player.health then
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.rectangle('fill', cellX, cellY, cellWidth, height - 4)
			love.graphics.setColor(0.5, 0, 0, 1)
			love.graphics.rectangle('line', cellX, cellY, cellWidth, height - 4)
		else
			love.graphics.setColor(0.1, 0.1, 0.1, 1)
			love.graphics.rectangle('line', cellX, cellY, cellWidth, height - 4)
		end
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print('Confidence', drawX, drawY - 20)
end

function drawOverWorldInterface(player)
	drawEnergyBar(player, love.graphics.getWidth() - 200, love.graphics.getHeight() - 50, 180)
	drawHealthBar(player, love.graphics.getWidth() - 150, love.graphics.getHeight() - 100, 130)
	drawPlayerMemorizedBooks(player, 5, love.graphics.getHeight() - 69)
	if player.usingInventory then
		drawPlayerInventory(player, 5, love.graphics.getHeight() - 94, 350, love.graphics.getHeight() - 120)
	end
	
	if player.targeting == 'examine' then
		local visionMap = player.currentWorld.visionMap
		local visionTile = getVisionTile(visionMap, player.targetX, player.targetY)
		
		local itemOffset = 0
		if player.examining then
			local drawX = love.graphics.getWidth()/2 - 200
			itemOffset = 350
			if love.graphics.getWidth() - (drawX + 600) < 200 then
				drawX = 10
				itemOffset = 160
			end
			drawEnemyDescription(player.examining, player, drawX, 20, 400, 400)
		end
		
		if visionTile >= 0 then
			local tile = getTile(player.currentWorld.map, player.targetX, player.targetY)
			if tile.book then
				local x = love.graphics.getWidth()/2 - 150 + itemOffset
				if player.examiningTargets == nil then
					player.examiningTargets = argumentInfo(tile.book.argument, x, 20, 400, 400, false, nil)
				else
					argumentInfo(tile.book.argument, x, 20, 400, 400, false, player.examiningTargets)
				end
			end
		end
	end
	
	if player.inCombat then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print('In Argument', 5, love.graphics.getHeight() - 84)
		
		activateTutorial('inCombat', {-200, -300})
	end
	
	local messageLeft = love.graphics.getWidth()/2 - 120
	if messageLeft < 340 then
		messageLeft = 340
	end
	
	drawImmediateMessage(messageLeft, love.graphics.getHeight() - 70, 240)
	drawHelpText(love.graphics.getWidth() - 210, 10, 200, player)
end

function drawPlayerMemorizedBooks(player, x, y)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(getImage('images/interface/books.png'), x, y)
	
	local bookLocations = {{x + 2, y + 2}, {x + 83, y + 2}, {x + 164, y + 2}, {x + 245, y + 2}}
	for i = 1, #player.memorizedBooks do
		if player.memorizedBooks[i] then
			local book = player.memorizedBooks[i].book
			local argument = getArgument(book)
			local image = loadImage(argument.image)
			local loc = bookLocations[i]
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(image.image, loc[1] + 1, loc[2] + 15)
			
			if math.abs(argument.energyCost) > 0 then
				local pillImage = loadImage('images/interface/energyPill.png')
				if argument.energyCost < 0 then
					pillImage = loadImage('images/interface/energyAdd.png')
				end
				local energyGap = math.ceil(20/argument.energyCost)
				
				local startX = 62 - (energyGap/2)*(math.abs(argument.energyCost) - 1)
				for j = 1, math.abs(argument.energyCost) do
					love.graphics.draw(pillImage.image, loc[1] + startX + (j - 1)*energyGap, loc[2] + 27, 0, 1, 1, math.ceil(pillImage.width/2), math.ceil(pillImage.height/2))
				end
			end
			
			if argument.energyCost > player.energy then
				love.graphics.setColor(0, 0, 0, 0.5)
				love.graphics.rectangle('fill', loc[1] + 1, loc[2] + 15, 44, 44)
			end
			
			if player.targetingArgument and player.targeting == 'argument' then
				if player.targetingArgument.name == argument.name then
					love.graphics.setColor(1, 0, 0, 0.5)
					love.graphics.rectangle('fill', loc[1] + 1, loc[2] + 15, 44, 44)
				end
			end
			
			if player.usingInventory == 'info' and player.chosenItem == book then
				love.graphics.setColor(1, 1, 0, 0.5)
				love.graphics.rectangle('fill', loc[1] + 1, loc[2] + 15, 44, 44)
			end
			
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.setFont(Fonts.bookDisplayFont)
			love.graphics.print(shortenTextToSize(argument.name, 72, 7), loc[1] + 2, loc[2] + 1)
		end
	end
end

function drawPlayerInventory(player, x, y, width, height)
	drawBorderedBacking(x, y - height, width, height)
	
	for i = 1, #player.booksHeld do
		local book = player.booksHeld[i].book
		local str = string.char(96 + i) .. ') ' .. book
		if player.usingInventory == 'info' and player.chosenItem == book then
			love.graphics.setColor(1, 1, 0, 1)
		elseif player.usingInventory and player.chosenItem == i then
			love.graphics.setColor(1, 1, 0, 1)
		elseif player.usingInventory == 'read' then
			local argument = getArgument(book)
			str = str .. ' |Energy cost: ' .. argument.energyCost .. '|'
			if argument.energyCost > player.energy then
				love.graphics.setColor(0.5, 0.5, 0.5, 1)
			elseif player.booksHeld[i].used then
				love.graphics.setColor(1, 0, 0, 1)
				str = str .. '--Already read'
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print(str, x + 5, y - height + 5 + (i - 1)*15)
	end
	
	if player.usingInventory == 'info' and player.chosenItem then
		local book = player.chosenItem
		local argument = getArgument(book)
		if player.examiningTargets == nil then
			player.examiningTargets = argumentInfo(argument, x + width, y - height, 400, 400, false, nil)
		else
			argumentInfo(argument, x + width, y - height, 400, 400, false, player.examiningTargets)
		end
	end
end

function drawEnemyDescription(enemy, player, x, y, width, height)
	drawBorderedBacking(x, y, width, height)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(Fonts.nameFont)
	love.graphics.printf(enemy.name, x + 10, y + 10, width - 20, 'left')
	love.graphics.setFont(Fonts.bookDisplayFont)
	love.graphics.printf(enemy.description, x + 10, y + 50, width - 20, 'left')
	if enemy.inCombat then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print('Engaged in argument', x + (width - 150), y + 35)
	elseif enemy.pacified then
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.print('Convinced', x + (width - 150), y + 35)
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	local patternTop = y + height/2 - 50
	love.graphics.print('Arguments:', x + 10, patternTop)
	for i = 1, #enemy.arguments do
		local argument = enemy.arguments[i]
		love.graphics.setColor(1, 1, 1, 1)
		if player.chosenItem == i then
			love.graphics.setColor(1, 1, 0, 1)
		end
		love.graphics.setFont(Fonts.bookDisplayFont)
		local text = string.char(96 + i) .. ') ' .. argument.name
		love.graphics.print(shortenTextToSize(text, 190, 7), x + 10, patternTop + (i - 1)*15 + 20)
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	local orderLeft = x + width/2
	love.graphics.print('Order:', orderLeft, patternTop)
	if enemy.initialPattern then
		local argument = enemy.initialPattern.argument
		love.graphics.print('Initial Argument: ' .. argument.name, orderLeft, patternTop + 20)
	end
	for i = 1, #enemy.pattern do
		local pattern = enemy.pattern[i]
		local text = 'wait'
		if pattern ~= 'wait' then
			love.graphics.setColor(1, 1, 1, 1)
			text = pattern.argument.name
		else
			love.graphics.setColor(0.6, 0.6, 0.6, 1)
		end
		if enemy.patternPosition == i then
			love.graphics.setColor(1, 1, 0, 1)
		end
		love.graphics.setFont(Fonts.bookDisplayFont)
		love.graphics.print(shortenTextToSize(text, 190, 7), orderLeft, patternTop + (i - 1)*15 + 45)
	end
	
	if player.chosenItem then
		if player.examiningTargets then
			player.examiningTargets = argumentInfo(enemy.arguments[player.chosenItem], x + width, y, 400, height, true, player.examiningTargets)
		else
			player.examiningTargets = argumentInfo(enemy.arguments[player.chosenItem], x + width, y, 400, height, true, nil)
		end
	end
end

function argumentInfo(argument, x, y, width, height, hostile, targets)
	local displaySize = height/2
	drawBorderedBacking(x, y, width, height)
	
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.setFont(Fonts.nameFont)
	love.graphics.printf(argument.name, x + 10, y + 10, width - 16, 'left')
	love.graphics.setFont(Fonts.bookDisplayFont)
	
	if not hostile then
		if argument.energyCost >= 0 then
			love.graphics.printf('Energy Cost: ' .. argument.energyCost, x + 110, y + 40, width - 16, 'left')
		else
			love.graphics.printf('Energy Supplied: ' .. math.abs(argument.energyCost), x + 110, y + 40, width - 16, 'left')
		end
	end
	love.graphics.printf(argument.description, x + 10, y + 60, width - 16, 'left')
	
	local tileSize = 44
	if 44*(2*argument.spaceRequired + 1) > displaySize then
		tileSize = displaySize/(2*argument.spaceRequired + 1)
	end
	
	local argumentCornerX = x + (width - (2*argument.spaceRequired + 1)*tileSize)/2
	love.graphics.print('Thought pattern', argumentCornerX, y + displaySize - 30)
	return displayArgument(argument, argumentCornerX, y + displaySize - 10, tileSize, tileSize, hostile, targets)
end

function displayArgument(argument, x, y, tileW, tileH, hostile, targets)
	x = math.floor(x)
	y = math.floor(y)
	local displaySize = 0
	if not targets then
		targets = {}
		local validLocations = {}
		for i = 1, #argument.targets do
			local target = argument.targets[i]
			local originX = 0
			local originY = 0
			if target.origin == 'last' then
				originX = targets[i - 1][1]
				originY = targets[i - 1][2]
			end
			
			while target.range + math.max(math.abs(originX), math.abs(originY)) > displaySize do
				displaySize = displaySize + 1
				local newTiles = findTileSquare(0, 0, displaySize)
				for j = 1, #newTiles do
					table.insert(validLocations, newTiles[j])
				end
			end
			
			local targetX = nil
			local targetY = 0
			local chosenIndex = 0
			local distance = 0
			while targetX == nil or distance > target.range do
				local chosenLocation = nil
				chosenLocation, chosenIndex = randomFromList(validLocations)
				targetX = chosenLocation[1]
				targetY = chosenLocation[2]
				
				distance = findCartesianDistance(targetX, targetY, originX, originY)
				if target.orthogonal then
					distance = findOrthogonalDistance(targetX, targetY, originX, originY)
				end
			end
			table.remove(validLocations, chosenIndex)
			table.insert(targets, {targetX, targetY})
		end
	end
	
	if #targets ~= #argument.targets then
		return nil
	end
	
	local mapSize = 2*argument.spaceRequired + 1
	local displayMap = newMap(mapSize, mapSize, 'floor', 'images/tiles/void.png')
	local displayWorld = newWorld(0)
	loadMapIntoWorld(displayWorld, displayMap, nil)
	revealVisionMap(displayWorld.visionMap)
	
	love.graphics.setColor(0, 0, 0, 0.4)
	love.graphics.rectangle('fill', x, y, mapSize*tileW, mapSize*tileH)
	
	for i = -argument.spaceRequired, argument.spaceRequired do
		for j = -argument.spaceRequired, argument.spaceRequired do
			if i ~= 0 or j ~= 0 then
				love.graphics.setColor(1, 1, 1, 0.3)
				love.graphics.rectangle('line', x + (i + argument.spaceRequired)*tileW, y + (j + argument.spaceRequired)*tileH, tileW, tileH)
			else
				love.graphics.setColor(1, 1, 1, 0.3)
				love.graphics.rectangle('fill', x + (i + argument.spaceRequired)*tileW, y + (j + argument.spaceRequired)*tileH, tileW, tileH)
			end
		end
	end
	
	local displayActor = newActor(nil)
	if not spawnActor(displayWorld, displayActor, 0, 0) then
		error()
	end
	
	argument.func(targets, displayActor)
	if not hostile then
		for i = 1, #displayWorld.thoughts do
			local thought = displayWorld.thoughts[i]
			thought.hostile = false
		end
	end
	
	local xOffset = x + (mapSize/2)*tileW
	local yOffset = y + (mapSize/2)*tileH
	drawThoughts(displayWorld.thoughts, displayWorld.visionMap, xOffset, yOffset, tileW, tileH, false)
	drawTargetingIndicators(argument, displayActor, targets, xOffset, yOffset, tileW, tileH)
	
	return targets
end