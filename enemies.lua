local enemyPatternBank = {}
local newPatternBankEntry = function(argument, targeting, baseWaitTime, initial, power)
	local pattern = {argument = getArgument(argument), name = argument, targeting = targeting, waitTime = baseWaitTime, initial = initial, power = power}
	table.insert(enemyPatternBank, pattern)
end
--1
newPatternBankEntry("Battlecry", {'player'}, 2, false, 3)
newPatternBankEntry("Loud yelling", {'player'}, 1, false, 2)
newPatternBankEntry("Point & yell", {'player'}, 1, false, 1)
newPatternBankEntry("Pretend listening", {'player'}, 1, false, 2)
newPatternBankEntry("Hurtful mockery", {'player'}, 2, false, 4)
newPatternBankEntry("Stubbornness", {}, 1, true, 3)
newPatternBankEntry("Snorble's principle", {'player'}, 1, false, 5)
--2
newPatternBankEntry("Accuse humanphilia", {'player'}, 1, false, 6)
newPatternBankEntry("Poignant reversal", {'player'}, 1, false, 7)
newPatternBankEntry("The Flurp gambit", {}, 1, true, 8)
newPatternBankEntry("Brandish weapons", {'player'}, 2, false, 8)
newPatternBankEntry("Claim cowardice", {'player'}, 2, true, 9)
--3
newPatternBankEntry('Plea sunk cost', {}, 2, true, 10)
newPatternBankEntry("The duality of man", {'player'}, 2, false, 11)
newPatternBankEntry('Appeal to authority', {'player'}, 2, true, 12)
newPatternBankEntry('Iron as a material of peace', {}, 2, true, 13)
newPatternBankEntry('Scoff and laugh', {'player'}, 1, false, 14)
newPatternBankEntry('Show off skulls', {'player'}, 1, false, 15)
newPatternBankEntry('Flat denial', {}, 3, true, 15)
newPatternBankEntry('Knuckle down', {'onPlayer'}, 1, true, 16)
newPatternBankEntry('Barely concealed agression', {'player'}, 1, false, 17)
--4
newPatternBankEntry('Gish gallop', {'player'}, 2, false, 18)
newPatternBankEntry('Deny argumentation', {}, 1, true, 19)
newPatternBankEntry('Absolute arrogance', {}, 3, true, 21)
newPatternBankEntry('Call a goblin', {'player'}, 2, false, 20)
newPatternBankEntry('Threaten death', {'player'}, 2, false, 17)
newPatternBankEntry('Threaten torture', {'player', 'player'}, 1, false, 20)
newPatternBankEntry('Macabre display', {}, 3, true, 21)
newPatternBankEntry('Shame ancestry', {'player'}, 3, false, 22)


function findPatternsInRange(start, finish)
	local patterns = {}
	for i = 1, #enemyPatternBank do
		if enemyPatternBank[i].power >= start and enemyPatternBank[i].power <= finish then
			table.insert(patterns, enemyPatternBank[i])
		end
	end
	return patterns
end

function findSpecificPattern(name)
	for i = 1, #enemyPatternBank do
		if enemyPatternBank[i].name == name then
			return {enemyPatternBank[i]}
		end
	end
end

function newEnemy(world, actor, x, y, pattern, initialPattern, name, description, hp, dropLevel, dropChance)
	local enemy = {enemy = true, pacified = false, inCombat = false, hp = hp, maxhp = hp, dropLevel = dropLevel, dropChance = dropChance, maxAngryTurns = 6, actor = actor, residingWorld = world, arguments = {}, pattern = {}, initialPattern = initialPattern, patternPosition = 0, activity = 'idle', warned = 0, name = name, description = description}
	if initialPattern then
		table.insert(enemy.arguments, initialPattern.argument)
		table.insert(enemy.pattern, 'wait')
	end
	enemy.actor.controller = enemy
	for i = 1, #pattern do
		local entry = pattern[i]
		local copiedPattern = copyPatternFromBank(entry[1], entry[2])
		table.insert(enemy.pattern, copiedPattern)
		
		local present = false
		for j = 1, #enemy.arguments do
			local argument = enemy.arguments[j]
			if argument.name == copiedPattern.argument.name then
				present = true
				break
			end
		end
		if not present then
			table.insert(enemy.arguments, copiedPattern.argument)
		end
			
		for j = 1, copiedPattern.waitTime do
			table.insert(enemy.pattern, 'wait')
		end
	end
	if spawnActor(world, actor, x, y) then
		table.insert(world.enemies, enemy)
		return enemy
	end
end

function selectPatternFromBank(patternName)
	for i = 1, #enemyPatternBank do
		local pattern = enemyPatternBank[i]
		if pattern.argument.name == patternName then
			return pattern
		end
	end
end

function copyPatternFromBank(pattern, additionalWait)
	local newPattern = {}
	newPattern.argument = pattern.argument
	newPattern.targeting = pattern.targeting
	newPattern.waitTime = pattern.waitTime + additionalWait
	return newPattern
end

function updateEnemies(world)
	for i = 1, #world.enemies do
		local enemy = world.enemies[i]
		updateEnemyAI(enemy)
	end
end

function updateEnemyAI(enemy)
	local agroed = false
	if not enemy.pacified then
		if getVisionTile(enemy.residingWorld.visionMap, enemy.actor.x, enemy.actor.y) >= 1 then
			increaseEnemyWarning(enemy, 1)
			if enemy.warned == 5 then
				if enemy.activity ~= 'combat' then
					agroEnemy(enemy)
					agroed = true
				end
			end
		else
			if enemy.warned > 1 and enemy.activity ~= 'combat' then
				increaseEnemyWarning(enemy, -1)
			end
		end
	end
	
	if not agroed then
		if enemy.activity == 'idle' then
			if math.random() < 0.5 then
				enemy.activity = 'wandering'
				selectEnemyWanderTarget(enemy)
			end
			addAction(enemy.residingWorld, newAction('rest', enemy.actor, 0, {}))
		elseif enemy.activity == 'wandering' then
			if enemy.actor.x == enemy.targetX and enemy.actor.y == enemy.targetY then
				enemy.activity = 'idle'
			else
				wanderEnemy(enemy)
			end
		elseif enemy.activity == 'combat' then
			enemyCombatCycle(enemy)
			if getVisionTile(enemy.residingWorld.visionMap, enemy.actor.x, enemy.actor.y) <= 0 then
				enemy.angryTurns = enemy.angryTurns - 1
				if enemy.angryTurns <= 0 then
					deAgroEnemy(enemy)
				end
			else
				enemy.angryTurns = enemy.maxAngryTurns
			end
		end
	end
end

function agroEnemy(enemy)
	if not enemy.pacified then
		enemy.activity = 'combat'
		enemy.inCombat = true
		enemy.warned = 5
		enemy.angryTurns = enemy.maxAngryTurns
		if enemy.initialPattern then
			useEnemyArgument(enemy, enemy.initialPattern.argument, enemy.initialPattern.targeting)
		end
		table.insert(enemy.residingWorld.agroedEnemies, enemy)
		clearThoughts(enemy.actor.parentMap, enemy.actor.x, enemy.actor.y, 3)
	end
end

function deAgroEnemy(enemy)
	enemy.activity = 'idle'
	enemy.inCombat = false
	enemy.patternPosition = 0
	for i = 1, #enemy.residingWorld.agroedEnemies do
		local compareEnemy = enemy.residingWorld.agroedEnemies[i]
		if compareEnemy == enemy then
			table.remove(enemy.residingWorld.agroedEnemies, i)
		end
	end
	
	enemy.hp = enemy.maxhp
end

function convinceEnemy(enemy)
	if enemy.hp == 1 then
		if enemy.king then
			if Player.currentLevel < #Levels then
				Player.levelComplete = true
				setImmediateMessage('You have convinced the leader of this dungeon! You may now move onto the next using (w).')
			else
				Player.victory = true
			end
		end
		deAgroEnemy(enemy)
		enemy.pacified = true
		enemy.warned = 0
		
		dropEnemyBook(enemy)
		activateTutorial('enemyConvinced', enemy.actor)
		
		if enemy.king then
			convinceAllEnemies(enemy.residingWorld)
		end
	else
		enemy.hp = enemy.hp - 1
	end
	
	if getVisionTile(World.visionMap, enemy.actor.x, enemy.actor.y) == 1 then
		imageBurst(enemy.actor.x, enemy.actor.y, 0.4, 0.4, {kind = 'image', image = loadImage('images/effects/pacifiedParticle.png'), angle = 0, sX = 1, sY = 1}, 10)
	end
end

function convinceAllEnemies(world)
	for i = 1, #world.enemies do
		local enemy = world.enemies[i]
		if not enemy.pacified then
			convinceEnemy(enemy)
		end
	end
end

function dropEnemyBook(enemy)
	local check = math.random()
	if check < enemy.dropChance then
		local dropBook = randomFromList(getArgumentsOfLevel(enemy.dropLevel))
		spawnBook(enemy.actor.parentMap, dropBook.name, enemy.actor.x, enemy.actor.y)
	end
end

function increaseEnemyWarning(enemy, amount)
	enemy.warned = enemy.warned + amount
	if enemy.warned < 0 then
		enemy.warned = 0
	elseif enemy.warned > 5 then
		enemy.warned = 5
	end
end

function enemyCombatCycle(enemy)
	enemy.patternPosition = enemy.patternPosition + 1
	if enemy.patternPosition > #enemy.pattern then
		enemy.patternPosition = 1
	end
	
	local enemyPatternEntry = enemy.pattern[enemy.patternPosition]
	if enemyPatternEntry == 'wait' then
		addAction(enemy.residingWorld, newAction('rest', enemy.actor, 0, {}))
	else
		useEnemyArgument(enemy, enemyPatternEntry.argument, enemyPatternEntry.targeting)
	end
end

function useEnemyArgument(enemy, argument, targeting)
	local targets = {}
	for i = 1, #targeting do
		local argumentTarget = argument.targets[i]
		local targetObject = targeting[i]
		
		local centerX = enemy.actor.x
		local centerY = enemy.actor.y
		if argumentTarget.origin == 'last' then
			centerX = targets[#targets][1]
			centerY = targets[#targets][2]
		end
		if targetObject == 'player' then
			local targetFound = false
			local i = 1
			local range = argumentTarget.range
			while not targetFound do
				local targetX, targetY = findTileAtAngle(math.atan2(Player.actor.y - centerY, Player.actor.x - centerX))
				targetX = centerX + range*targetX
				targetY = centerY + range*targetY
				if checkArgumentFits(targetX, targetY, targets, argument, enemy.actor) or range <= 1 then
					table.insert(targets, {targetX, targetY})
					targetFound = true
				else
					range = range - 1
				end
				
				if i > 1000 then
					error(range)
				else
					i = i + 1
				end
			end
		elseif targetObject == 'onPlayer' then
			local targetFound = false
			local i = 1
			local range = argumentTarget.range
			while not targetFound do
				local targetX = Player.actor.x
				local targetY = Player.actor.y
				if findCartesianDistance(targetX, targetY, enemy.actor.x, enemy.actor.y) > range then
					targetX, targetY = findTileAtAngle(math.atan2(Player.actor.y - enemy.actor.y, Player.actor.x - enemy.actor.x))
					targetX = centerX + range*targetX
					targetY = centerY + range*targetY
					if checkArgumentFits(targetX, targetY, targets, argument, enemy.actor) or range <= 1 then
						table.insert(targets, {targetX, targetY})
						targetFound = true
					else
						range = range - 1
					end
					
					if i > 1000 then
						error(range)
					else
						i = i + 1
					end
				else
					targetFound = true
					table.insert(targets, {targetX, targetY})
				end
			end
		elseif targetObject == 'random' then
			local validTargets = seeTiles(enemy.actor.parentMap, centerX, centerY, argumentTarget.range)
			if #validTargets == 0 then
				table.insert(targets, {centerX + 1, centerY})
			else
				while #validTargets > 0 do
					local target, index = randomFromList(validTargets)
					if checkArgumentFits(target[1], target[2], targets, argument, enemy.actor) or #validTargets == 1 then
						table.insert(targets, {target[1], target[2]})
						table.remove(validTargets, index)
						break
					end
				end
			end
		end
	end
	addAction(enemy.residingWorld, newAction('argument', enemy.actor, 3, {argument = argument, targets = targets}))
end

function wanderEnemy(enemy)
	local angle = math.atan2(enemy.targetY - enemy.actor.y, enemy.targetX - enemy.actor.x)
	local xDir, yDir = findTileAtAngle(angle)
	local targetX = enemy.actor.x + xDir
	local targetY = enemy.actor.y + yDir
	while checkProperties(getTile(enemy.actor.parentMap, targetX, targetY), {blocksWalker = true}) do
		angle = angle + plusOrMinus()*math.pi/4
		xDir, yDir = findTileAtAngle(angle)
		targetX = enemy.actor.x + xDir
		targetY = enemy.actor.y + yDir
	end
	addAction(enemy.residingWorld, newAction('move', enemy.actor, 1, {xDir = xDir, yDir = yDir}))
	
	if enemy.wanderTime <= 0 then
		enemy.activity = 'idle'
	else
		enemy.wanderTime = enemy.wanderTime - 1
	end
end

function selectEnemyWanderTarget(enemy)
	local map = enemy.actor.parentMap
	local viableTiles = seeTiles(map, enemy.actor.x, enemy.actor.y, 20)
	local i = 1
	while i <= #viableTiles do
		local x = viableTiles[i][1]
		local y = viableTiles[i][2]
		local mapTile = getTile(map, x, y)
		if checkProperties(mapTile, {blocksWalker = true}) then
			table.remove(viableTiles, i)
		else
			i = i + 1
		end
	end
	
	local chosenTile = randomFromList(viableTiles)
	enemy.targetX = chosenTile[1]
	enemy.targetY = chosenTile[2]
	enemy.wanderTime = findCartesianDistance(enemy.actor.x, enemy.actor.y, chosenTile[1], chosenTile[2])
end

function drawEnemies(enemies, visionMap, xOffset, yOffset, tileW, tileH)
	for i = 1, #enemies do
		local enemy = enemies[i]
		if getVisionTile(visionMap, enemy.actor.x, enemy.actor.y) >= 1 then
			drawEnemy(enemy, xOffset, yOffset, tileW, tileH)
		end
	end
end

function drawEnemy(enemy, xOffset, yOffset, tileW, tileH)
	love.graphics.setColor(1, 1, 1, 1)
	if enemy.warned > 1 then
		if enemy.warned == 5 then
			drawImageOnTile(loadImage('images/effects/angry.png'), enemy.actor.x, enemy.actor.y, 0, xOffset, yOffset, tileW, tileH)
		else
			local image = 'images/effects/warned' .. enemy.warned - 1 .. '.png'
			drawImageOnTile(loadImage(image), enemy.actor.x, enemy.actor.y, 0, xOffset, yOffset, tileW, tileH)
		end
	elseif enemy.pacified then
		drawImageOnTile(loadImage('images/effects/pacified.png'), enemy.actor.x, enemy.actor.y, 0, xOffset, yOffset, tileW, tileH)
	end
	
	if enemy.king then
		drawImageOnTile(loadImage('images/effects/king.png'), enemy.actor.x, enemy.actor.y, 0, xOffset, yOffset, tileW, tileH)
	end
	
	if enemy.hp < enemy.maxhp then
		drawEnemyHealthBar(enemy, xOffset, yOffset, tileW, tileH)
	end
end

function drawEnemyHealthBar(enemy, xOffset, yOffset, tileW, tileH)
	local drawX = math.ceil((enemy.actor.x + 0.3)*tileW + xOffset)
	local drawY = math.ceil((enemy.actor.y - 0.4)*tileH + yOffset)
	local sX = tileW/44
	local sY = tileH/44
	
	local barWidth = 6*sX
	local barHeight = 30*sY
	local cellSize = barHeight/enemy.maxhp
	for i = 1, enemy.maxhp do
		local cellX = drawX
		local cellY = drawY + (enemy.maxhp - i)*cellSize
		if i <= enemy.hp then
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.rectangle('fill', cellX, cellY, barWidth, cellSize)
			love.graphics.setColor(0.5, 0, 0, 1)
			love.graphics.rectangle('line', cellX, cellY, barWidth, cellSize)
		else
			love.graphics.setColor(0.1, 0.1, 0.1, 1)
			love.graphics.rectangle('fill', cellX, cellY, barWidth, cellSize)
		end
	end
end