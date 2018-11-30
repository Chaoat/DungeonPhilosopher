function innitiatePlayer()
	local player = {actor = newActor('images/actors/player.png'), controls = {}, currentWorld = nil, currentLevel = 1, levelComplete = false, energy = 4, maxEnergy = 4, health = 7, maxHealth = 7, targetX = 0, targetY = 0, targeting = false, examining = false, usingInventory = false, chosenItem = false, memorizedBooks = {false, false, false, false}, booksHeld = {}, inCombat = false, viewDistance = 12, dead = false, victory = false, turnsProcessed = 0}
	player.actor.controller = player
	
	player.controls['kp1'] = 'downLeft'
	player.controls['kp2'] = 'down'
	player.controls['kp3'] = 'downRight'
	player.controls['kp4'] = 'left'
	player.controls['kp5'] = 'skip'
	player.controls['5'] = 'skip'
	player.controls['kp6'] = 'right'
	player.controls['kp7'] = 'upLeft'
	player.controls['kp8'] = 'up'
	player.controls['kp9'] = 'upRight'
	
	player.controls['lalt'] = 'viewLastTurn'
	player.controls['x'] = 'examine'
	player.controls['i'] = 'infoInventory'
	player.controls['e'] = 'equip'
	player.controls['g'] = 'grab'
	player.controls['s'] = 'swap'
	player.controls['r'] = 'read'
	
	player.controls['1'] = 'book1'
	player.controls['2'] = 'book2'
	player.controls['3'] = 'book3'
	player.controls['4'] = 'book4'
	
	player.controls['return'] = 'accept'
	player.controls['kpenter'] = 'accept'
	player.controls['space'] = 'accept'
	player.controls['escape'] = 'cancel'
	
	player.controls['w'] = 'win'
	player.controls['t'] = 'tutorial'
	player.controls['d'] = 'restart'
	player.controls['q'] = 'quit'
	
	selectPlayerStartingArguments(player, 2)
	--givePlayerBook(player, getArgument("Perfect deflection"))
	--givePlayerBook(player, getArgument("Speegle's argument for peace"))
	--givePlayerBook(player, getArgument("Reiterate axioms"))
	--givePlayerBook(player, getArgument("Relate personal experience"))
	return player
end

function selectPlayerStartingArguments(player, number)
	local possibleArguments = getArgumentsOfLevel(0)
	for i = 1, number do
		local argument, index = randomFromList(possibleArguments)
		givePlayerBook(player, argument)
		table.remove(possibleArguments, index)
	end
end

function playerControlHeld(player, control)
	for key, value in pairs(player.controls) do
		if value == control then
			if love.keyboard.isDown(key) then
				return true
			end
		end
	end
	return false
end

function placePlayerInWorld(player, world, x, y)
	while not spawnActor(world, player.actor, x, y) do
		x = x + math.ceil(math.random()*3 - 2)
		y = y + math.ceil(math.random()*3 - 2)
	end
	player.currentWorld = world
end

function damagePlayer(player, amount)
	player.health = player.health - amount
	if player.health <= 0 and debugSettings.allowPlayerDeath then
		player.dead = true
	end
	imageBurst(player.actor.x, player.actor.y, 0.4, 0.4, {kind = 'image', image = loadImage('images/effects/angryParticle.png'), angle = 0, sX = 1, sY = 1}, 10)
	activateTutorial('damage', {-100, -200})
end

function checkPlayerInput(player, key)
	if player.controls[key] == 'tutorial' then
		debugSettings.enableTutorial = flipBoolean(debugSettings.enableTutorial)
	end
	if player.dead or player.victory then
		if player.controls[key] == 'restart' then
			debugSettings.enableTutorial = false
			startGame()
		elseif player.controls[key] == 'quit' then
			love.event.quit()
		end
	end
	
	if not player.dead then
		if player.usingInventory then
			if player.controls[key] == 'cancel' then
				player.usingInventory = false
			elseif player.usingInventory == 'equip' then
				playerEquip(player, key)
			elseif player.usingInventory == 'info' then
				playerChooseItem(player, key)
			elseif player.usingInventory == 'swap' then
				playerSwap(player, key)
			elseif player.usingInventory == 'read' then
				playerRead(player, key)
			end
		else
			if player.examining then
				playerChooseEnemyArgument(player, key)
			end
			
			if player.controls[key] then
				if player.controls[key] == 'downLeft' then
					playerCursor(player, -1, 1)
				elseif player.controls[key] == 'down' then
					playerCursor(player, 0, 1)
				elseif player.controls[key] == 'downRight' then
					playerCursor(player, 1, 1)
				elseif player.controls[key] == 'left' then
					playerCursor(player, -1, 0)
				elseif player.controls[key] == 'right' then
					playerCursor(player, 1, 0)
				elseif player.controls[key] == 'upLeft' then
					playerCursor(player, -1, -1)
				elseif player.controls[key] == 'up' then
					playerCursor(player, 0, -1)
				elseif player.controls[key] == 'upRight' then
					playerCursor(player, 1, -1)
				elseif player.controls[key] == 'skip' then
					playerCursor(player, 0, 0)
				elseif player.controls[key] == 'accept' then
					acceptPlayerFunction(player)
				elseif player.controls[key] == 'cancel' then
					player.examining = false
					player.targeting = false
					player.examiningTargets = nil
					cameraX = player.actor.x
					cameraY = player.actor.y
				elseif player.controls[key] == 'book1' then
					pickPlayerBook(player, 1)
				elseif player.controls[key] == 'book2' then
					pickPlayerBook(player, 2)
				elseif player.controls[key] == 'book3' then
					pickPlayerBook(player, 3)
				elseif player.controls[key] == 'book4' then
					pickPlayerBook(player, 4)
				elseif player.controls[key] == 'win' then
					playerWin(player)
				end
				
				if not player.targeting then
					if player.controls[key] == 'infoInventory' then
						player.chosenItem = nil
						innitiateInventory(player, 'info')
						setImmediateMessage('Select book to view info on ' .. listLetterRange(player.booksHeld))
						activateTutorial('memorized', {-220, 300})
					elseif player.controls[key] == 'equip' then
						if not player.inCombat then
							player.chosenItem = nil
							innitiateInventory(player, 'equip')
							setImmediateMessage('Select book to memorize ' .. listLetterRange(player.booksHeld))
						end
					elseif player.controls[key] == 'swap' then
						player.chosenItem = nil
						innitiateInventory(player, 'swap')
						setImmediateMessage('Select book to swap ' .. listLetterRange(player.booksHeld))
					elseif player.controls[key] == 'examine' then
						innitiateTargeting(player, 'examine')
					elseif player.controls[key] == 'read' then
						player.chosenItem = nil
						innitiateInventory(player, 'read')
					elseif player.controls[key] == 'grab' then
						pickupBook(player)
					end
				end
			end
		end
	end
end

function playerWin(player)
	if player.levelComplete then
		loadLevel(player.currentLevel + 1)
		player.maxEnergy = player.maxEnergy + 3
		player.health = player.maxHealth
	end
end

function acceptPlayerFunction(player)
	if player.targeting == 'argument' then
		local nTargets = #player.targets
		if targetArgument(player.targetX, player.targetY, player.targets, player.targetingArgument, player.actor) then
			usePlayerAction(player)
		else
			local description = player.targetingArgument.targets[#player.targets + 1].description
			if nTargets == #player.targets then
				description = 'Invalid selection'
			end
			setImmediateMessage(description)
		end
	end
end

function pickPlayerBook(player, book)
	player.chosenItem = nil
	if player.memorizedBooks[book] then
		if player.targeting == false then
			local argument = getArgument(player.memorizedBooks[book].book)
			selectPlayerArgument(player, argument)
		elseif player.targeting == 'argument' then
			if player.targetingArgument.name == player.memorizedBooks[book].book then
				acceptPlayerFunction(player)
			end
		end
	end
end

function selectPlayerArgument(player, argument)
	if player.energy >= argument.energyCost then
		if #argument.targets > 0 then
			innitiateTargeting(player, 'argument')
			player.targets = {}
			player.targetingArgument = argument
			setImmediateMessage(player.targetingArgument.targets[1].description)
		else
			player.targetingArgument = argument
			usePlayerAction(player)
		end
	else
		setImmediateMessage('Not enough energy')
	end
end

function innitiateTargeting(player, targeting)
	player.targeting = targeting
	player.targetX = player.actor.x
	player.targetY = player.actor.y
end

function innitiateInventory(player, inventory)
	player.targeting = false
	player.usingInventory = inventory
end

function playerEquip(player, key)
	if player.chosenItem then
		local index = tonumber(key)
		if index then
			if index >= 1 and index <= 4 then
				local swappedItem = player.memorizedBooks[index]
				if player.inCombat then
					swappedItem.used = false
				end
				player.memorizedBooks[index] = player.booksHeld[player.chosenItem]
				player.booksHeld[player.chosenItem] = swappedItem
				player.usingInventory = false
			end
		end
	else
		if checkCharacterInRange(key) then
			local index = string.byte(key) - 96
			if index <= #player.booksHeld then
				player.chosenItem = index
				setImmediateMessage('Select slot to memorize book to (1 - 4)')
			end
		end
	end
end

function playerChooseItem(player, key)
	if checkCharacterInRange(key) then
		local index = string.byte(key) - 96
		if index <= #player.booksHeld then
			player.examiningTargets = nil
			player.chosenItem = player.booksHeld[index].book
		end
	elseif key == '1' then
		if player.memorizedBooks[1] then
			player.examiningTargets = nil
			player.chosenItem = player.memorizedBooks[1].book
		end
	elseif key == '2' then
		if player.memorizedBooks[2] then
			player.examiningTargets = nil
			player.chosenItem = player.memorizedBooks[2].book
		end
	elseif key == '3' then
		if player.memorizedBooks[3] then
			player.examiningTargets = nil
			player.chosenItem = player.memorizedBooks[3].book
		end
	elseif key == '4' then
		if player.memorizedBooks[4] then
			player.examiningTargets = nil
			player.chosenItem = player.memorizedBooks[4].book
		end
	end
end

function playerSwap(player, key)
	if player.chosenItem then
		local index = tonumber(key)
		if checkCharacterInRange(key) then
			local index = string.byte(key) - 96
			if index <= #player.booksHeld then
				local swappedItem = player.booksHeld[index]
				player.booksHeld[index] = player.booksHeld[player.chosenItem]
				player.booksHeld[player.chosenItem] = swappedItem
				
				player.chosenItem = nil
				innitiateInventory(player, 'swap')
				setImmediateMessage('Select book to swap ' .. listLetterRange(player.booksHeld))
			end
		end
	else
		if checkCharacterInRange(key) then
			local index = string.byte(key) - 96
			if index <= #player.booksHeld then
				player.chosenItem = index
				setImmediateMessage('Select slot to switch with ' .. listLetterRange(player.booksHeld))
			end
		end
	end
end

function playerRead(player, key)
	if checkCharacterInRange(key) then
		local index = string.byte(key) - 96
		if index <= #player.booksHeld then
			if not player.booksHeld[index].used then
				player.chosenItem = index
				local argument = getArgument(player.booksHeld[index].book)
				player.usingInventory = false
				selectPlayerArgument(player, argument)
			end
		end
	end
end

function playerChooseEnemyArgument(player, key)
	if checkCharacterInRange(key) then
		local index = string.byte(key) - 96
		if index <= #player.examining.arguments then
			player.examiningTargets = nil
			player.chosenItem = index
		end
	end
end

function usePlayerAction(player)
	addPlayerEnergy(player, -player.targetingArgument.energyCost)
	addAction(player.currentWorld, newAction('argument', player.actor, 3, {argument = player.targetingArgument, targets = player.targets}))
	player.targetingArgument = nil
	player.targeting = false
	if player.chosenItem then
		player.booksHeld[player.chosenItem].used = true
	end
	endPlayerTurn(player)
end

function addPlayerEnergy(player, n)
	player.energy = player.energy + n
	if player.energy < 0 then
		player.energy = 0
	elseif player.energy > player.maxEnergy then
		player.energy = player.maxEnergy
	end
end

function playerCursor(player, xDir, yDir)
	if not player.targeting then
		movePlayer(player, xDir, yDir)
	elseif player.targeting == 'examine' then
		player.targetX = player.targetX + xDir
		player.targetY = player.targetY + yDir
		cameraX = player.targetX
		cameraY = player.targetY
		player.examiningTargets = nil
		player.chosenItem = nil
		
		local visionTile = getVisionTile(player.currentWorld.visionMap, player.targetX, player.targetY)
		player.examining = false
		if visionTile >= 1 then
			local tile = getTile(player.currentWorld.map, player.targetX, player.targetY)
			if tile.actor then
				if tile.actor.controller.enemy then
					local enemy = tile.actor.controller
					player.examining = enemy
					player.chosenItem = false
				end
			end
		end
	elseif player.targeting == 'argument' then
		local range = 0
		if player.targetingArgument then
			range = player.targetingArgument.targets[#player.targets + 1].range
		end
		
		local centerX = player.actor.x
		local centerY = player.actor.y
		if player.targetingArgument.targets[#player.targets + 1].origin == 'last' then
			centerX = player.targets[#player.targets][1]
			centerY = player.targets[#player.targets][2]
		end
		
		local newX = player.targetX + xDir
		local newY = player.targetY + yDir
		local distance = findCartesianDistance(centerX, centerY, newX, newY)
		if player.targetingArgument.targets[#player.targets + 1].orthogonal then
			distance = findOrthogonalDistance(centerX, centerY, newX, newY)
		end
		if range == 0 or distance <= range then
			player.targetX = newX
			player.targetY = newY
		end
	end
end

function movePlayer(player, xDir, yDir)
	if xDir == 0 and yDir == 0 then
		addAction(player.currentWorld, newAction('rest', player.actor, 0, {}))
		addPlayerEnergy(player, 1)
	else
		addAction(player.currentWorld, newAction('move', player.actor, 1, {xDir = xDir, yDir = yDir}))
	end
	endPlayerTurn(player)
end

function endPlayerTurn(player)
	processTurn(player.currentWorld)
	if #player.currentWorld.agroedEnemies > 0 then
		player.inCombat = true
	else
		player.inCombat = false
		addPlayerEnergy(player, 1)
	end
	
	if player.inCombat == false then
		for i = 1, #player.booksHeld do
			player.booksHeld[i].used = false
		end
	end
	
	if not player.victory then
		player.turnsProcessed = player.turnsProcessed + 1
	end
end