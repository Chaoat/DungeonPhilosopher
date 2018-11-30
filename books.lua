function placeBook(map, argument, x, y)
	local book = {x = x, y = y, argument = getArgument(argument)}
	local mapTile = getTile(map, x, y)
	if checkProperties(mapTile, {blocksWalker = false}) then
		mapTile.book = book
	end
end

function getRandomArgument(level)
	local possibleArguments = getArgumentsOfLevel(level)
	if #possibleArguments > 0 then
		local argument, index = randomFromList(possibleArguments)
		return argument
	else
		return false
	end
end

function spawnBook(map, argument, x, y)
	local mapTile = getTile(map, x, y)
	local iterations = 0
	while checkProperties(mapTile, {blocksWalker = true}) do
		x = x + plusOrMinus()
		y = y + plusOrMinus()
		mapTile = getTile(map, x, y)
		if iterations > 1000 then
			return
		else
			iterations = iterations + 1
		end
	end
	placeBook(map, argument, x, y)
end

function givePlayerBook(player, argument)
	argument = argument.name
	local book = {book = argument, used = false}
	if player.inCombat then
		book.used = true
	end
	
	if not checkBookOwnedByPlayer(player, argument) then
		for i = 1, #player.memorizedBooks do
			local memorizedBook = player.memorizedBooks[i]
			if not memorizedBook then
				player.memorizedBooks[i] = book
				return true
			end
		end
		table.insert(player.booksHeld, book)
		return true
	else
		return false
	end
end

function checkBookOwnedByPlayer(player, argumentName)
	for i = 1, #player.memorizedBooks do
		local memorizedBook = player.memorizedBooks[i]
		if memorizedBook then
			if memorizedBook.book == argumentName then
				return true
			end
		end
	end
	for i = 1, #player.booksHeld do
		if player.booksHeld[i].book == argumentName then
			return true
		end
	end
	return false
end

function pickupBook(player)
	local actor = player.actor
	local standingTile = getTile(actor.parentMap, actor.x, actor.y)
	if standingTile.book then
		if givePlayerBook(player, standingTile.book.argument) then
			standingTile.book = nil
		else
			setImmediateMessage('You already have that book')
		end
	end
end

function generateBooks(map, rooms, nBooks)
	local possibleEntrances = {}
	for i = 1, #rooms do
		local room = rooms[i]
		local suitableEntrances = {}
		for i = 1, #room.entrances do
			local entrance = room.entrances[i]
			if not entrance.used then
				table.insert(suitableEntrances, entrance)
			end
		end
		
		local entrance = randomFromList(suitableEntrances)
		local sortingValue = #room.adjacent - (room.distance/#room.adjacent)
		binaryInsert(possibleEntrances, 'sortingValue', {entrance = entrance, sortingValue = sortingValue}, true)
	end
	
	for i = 1, #nBooks do
		local iterations = 0
		local level = #nBooks - i
		local number = nBooks[level + 1]
		while #possibleEntrances > 0 and number > 0 do
			local entrance = possibleEntrances[1].entrance
			local distance = math.ceil(math.random()*4)
			
			local chosenTile = randomFromList(entrance.tiles)
			local x = chosenTile[1] - entrance.xD*distance
			local y = chosenTile[2] - entrance.yD*distance
			spawnBook(map, getRandomArgument(level).name, x, y)
			table.remove(possibleEntrances, 1)
			number = number - 1
			if iterations > 1000 then
				error('Cannot spawn books')
			else
				iterations = iterations + 1
			end
		end
	end
end