local goblinNameTable = {
'Frblthrp',
'Urk',
'Grug',
'Sore',
'Grimble',
'Phirp'
}
local minotaurNames = {
'Butch',
'Minas',
'Theodore',
'Mythras',
'Daisy',
'Fido',
'Bull',
'Horns',
'Axe'
}
local knightNames = {
'Morthos',
'Morder',
'Mordred',
'Morte',
'Mord',
'Vlad',
'Impaler',
'Soul-Eater'
}

local speciesTable = {}
speciesTable['goblin'] = {image = 'images/actors/goblin.png', nameTable = goblinNameTable, nNames = 1, description = 
'A fellow member of your diminutive species. Unfortunately for you, this individual seems to have embraced some of the more negative stereotypes of your people.'}
speciesTable['minotaur'] = {image = 'images/actors/minotaur.png', nameTable = minotaurNames, nNames = 2, description = 
'The ferocious minotaur has been a well respected member of the dungeon community for longer than history can remember. It will be a tough effort to change their ancestral ways.'}
speciesTable['knight'] = {image = 'images/actors/deathKnight.png', nameTable = knightNames, nNames = 3, description = 
'A member of the ferocious deathknight caste is a rare sight for a mere goblin such as yourself. They are said to have a dark finger in the affairs of all the dungeons in the world, so convincing them of your philosophy would be a momentous achievement.'}

function generateName(nameTable, number)
	local name = randomFromList(nameTable)
	for i = 1, number - 1 do
		name = name .. ' ' .. randomFromList(nameTable)
	end
	return name
end

function newEnemyTable(species, power, nArguments, initialArgument, number, hp, dropLevel, dropChance)
	return {species = species, power = power, nArguments = nArguments, initialArgument = initialArgument, number = number, hp = hp, dropLevel = dropLevel, dropChance = dropChance}
end

function findRoomsInRange(rooms, start, finish)
	local goodRooms = {}
	for i = 1, #rooms do
		if rooms[i].distance >= start and rooms[i].distance <= finish then
			table.insert(goodRooms, rooms[i])
		end
	end
	return goodRooms
end

function generateEnemies(world, rooms, enemies, king)
	local maxDistance = findMaxDistance(rooms)
	local maxPower = king.power
	local powerMultiple = maxDistance/maxPower
	
	for i = 1, #enemies + 1 do
		local enemyTable = king
		if i <= #enemies then
			enemyTable = enemies[i]
		end
		for j = 1, enemyTable.number do
			local spawned = false
			local iteration = 0
			while not spawned do
				local minDistance = enemyTable.power*powerMultiple
				local okayRooms = findRoomsInRange(rooms, minDistance, maxDistance)
				while #okayRooms == 0 do
					minDistance = minDistance - 1
					okayRooms = findRoomsInRange(rooms, minDistance, maxDistance)
					if iteration > 1000 then
						error('Cannot find okay room')
					else
						iteration = iteration + 1
					end
				end
				local spawnRoom = randomFromList(okayRooms)
				local spawnTile = randomFromList(spawnRoom.tileTypes['floor'])
				
				local king = false
				if i == #enemies + 1 then
					king = true
				end
				spawned = generateEnemy(world, spawnTile.x, spawnTile.y, enemyTable.species, enemyTable.power, enemyTable.nArguments, enemyTable.initialArgument, enemyTable.hp, enemyTable.dropLevel, enemyTable.dropChance, king)
				if iteration > 1000 then
					error('Enemy cannot spawn')
				else
					iteration = iteration + 1
				end
			end
		end
	end
end

function findMaxDistance(rooms)
	local dist = 0
	for i = 1, #rooms do
		local room = rooms[i]
		if room.distance > dist then
			dist = room.distance
		end
	end
	return dist
end

function generateEnemy(world, x, y, species, power, nArguments, initialArgument, hp, dropLevel, dropChance, king)
	power = power + plusOrMinus()*math.floor(math.random()*2)
	
	local patterns = {}
	local initialPattern = nil
	
	local powerRange = 3
	if initialArgument then
		local possibleInitialPatterns = findPatternsInRange(power - powerRange, power)
		local i = 1
		while i <= #possibleInitialPatterns do
			if possibleInitialPatterns[i].initial then
				i = i + 1
			else
				table.remove(possibleInitialPatterns, i)
			end
		end
		if #possibleInitialPatterns > 0 then
			initialPattern = randomFromList(possibleInitialPatterns)
		end
	end
	
	local powerDecrease = (power - 3)/nArguments
	if powerDecrease < 0 then
		powerDecrease = 0
	end
	
	local iterations = 0
	while nArguments > 0 do
		local possiblePatterns = findPatternsInRange(power - powerRange, power)
		--local possiblePatterns = findPatternsInRange(99, 99)
		if #possiblePatterns > 0 then
			local pattern = randomFromList(possiblePatterns)
			insertAtRandom(patterns, {pattern, 0})
			
			nArguments = nArguments - 1
			power = power - powerDecrease
		else
			powerRange = powerRange + 2
		end
		
		if iterations > 1000 then
			error('Cannot decide arguments')
		else
			iterations = iterations + 1
		end
	end
	
	local name = generateName(speciesTable[species].nameTable, speciesTable[species].nNames)
	local description = speciesTable[species].description
	local image = speciesTable[species].image
	
	local enemy = newEnemy(world, newActor(image), x, y, patterns, initialPattern, name, description, hp, dropLevel, dropChance)
	if enemy then
		if king then
			enemy.king = true
		end
		return true
	else
		return false
	end
end