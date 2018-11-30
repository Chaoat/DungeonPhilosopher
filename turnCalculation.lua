function addAction(world, action)
	binaryInsert(world.actions, 'order', action, true)
end

function newAction(name, actor, order, properties)
	local action = {name = name, order = order, actor = actor}
	for key, value in pairs(properties) do
		action[key] = value
	end
	return action
end

function processActorActions(world)
	for i = 1, #world.actions do
		local nextAction = world.actions[i]
		if nextAction.name == 'move' then
			moveActorInDirection(nextAction.actor, nextAction.xDir, nextAction.yDir)
		elseif nextAction.name == 'rest' then
			
		elseif nextAction.name == 'argument' then
			local argument = nextAction.argument
			local targets = nextAction.targets
			argument.func(targets, nextAction.actor)
		end
	end
	world.actions = {}
end

function processTurn(world)
	updateTutorials()
	setImmediateMessage(nil)
	world.turnN = world.turnN + 1
	
	updateEnemies(world)
	
	processActorActions(world)
	updateThoughts(world)
	
	seeInWorld(World, Player.actor.x, Player.actor.y, Player.viewDistance)
	cameraX = Player.actor.x
	cameraY = Player.actor.y
	
	if world.turnN == 5 then
		activateTutorial('inventory', {-350, -350})
	end
end