function innitiateLevelList()
	Levels = {}
	Levels[1] = {size = 40, enemies = {newEnemyTable('goblin', 5, 2, false, 12, 1, 0, 0.3),
	newEnemyTable('minotaur', 8, 2, true, 3, 1, 1, 1)}, 
	king = newEnemyTable('goblin', 13, 3, true, 1, 3, 2, 1), books = {10, 5}}
	
	Levels[2] = {size = 50, enemies = {newEnemyTable('goblin', 8, 2, false, 5, 1, 1, 1), 
	newEnemyTable('minotaur', 12, 2, true, 12, 1, 2, 0.3), 
	newEnemyTable('knight', 16, 3, true, 3, 1, 2, 1)}, 
	king = newEnemyTable('minotaur', 18, 3, true, 1, 3, 3, 1), books = {0, 15, 10}}
	
	Levels[3] = {size = 60, enemies = {newEnemyTable('goblin', 10, 3, false, 1, 1, 2, 1), 
	newEnemyTable('minotaur', 16, 2, true, 8, 1, 2, 0.3),
	newEnemyTable('knight', 20, 3, true, 8, 1, 3, 0.5)}, 
	king = newEnemyTable('knight', 23, 4, true, 1, 3, 3, 1), books = {0, 0, 15, 10}}
end

function loadLevel(level)
	World = newWorld(Levels[level].size, Levels[level].enemies, Levels[level].king, Levels[level].books)
	placePlayerInWorld(Player, World, 0, 0)
	processTurn(World)
	
	Player.currentLevel = level
	Player.levelComplete = false
end

function newWorld(nRooms, enemies, king, books)
	local map, rooms = generateMap(nRooms, 1)
	local world = {map = map, actors = {}, enemies = {}, agroedEnemies = {}, actions = {}, thoughts = {}, lastTurnThoughts = {}, visionMap = innitiateVisionMap(map), turnN = 0}
	map.parentWorld = world
	
	if enemies then
		generateEnemies(world, rooms, enemies, king)
	end
	if books then
		generateBooks(map, rooms, books)
	end
	return world
end

function loadMapIntoWorld(world, map)
	world.map = map
	map.parentWorld = world
	world.visionMap = innitiateVisionMap(map)
end

function spawnActor(world, actor, x, y)
	if moveActor(world.map, actor, x, y) then
		table.insert(world.actors, actor)
		return true
	else
		return false
	end
end

function seeInWorld(world, x, y, r)
	local seenTiles = seeTiles(world.map, x, y, r)
	updateVisionMap(world.visionMap, seenTiles)
end

function revealWorld(world)
	revealVisionMap(world.visionMap)
end

function drawWorld(world, tileW, tileH)
	local xOffset = love.graphics.getWidth()/2 - cameraX*tileW
	local yOffset = love.graphics.getHeight()/2 - cameraY*tileH
	drawMap(world.map, world.visionMap, xOffset, yOffset, tileW, tileH)
	drawActors(world.actors, world.visionMap, xOffset, yOffset, tileW, tileH)
	drawEnemies(world.enemies, world.visionMap, xOffset, yOffset, tileW, tileH)
	drawThoughts(world.thoughts, world.visionMap, xOffset, yOffset, tileW, tileH, false)
	if playerControlHeld(Player, 'viewLastTurn') then
		drawThoughts(world.lastTurnThoughts, world.visionMap, xOffset, yOffset, tileW, tileH, true)
	end
	drawShadows(world.visionMap, xOffset, yOffset, tileW, tileH)
	drawParticles(Particles, xOffset, yOffset, tileW, tileH)
	drawInWorldInterface(world, Player, xOffset, yOffset, tileW, tileH)
	
	if debugSettings.showConnections then
		drawRoomConnections(world.rooms, xOffset, yOffset, tileW, tileH)
	end
end