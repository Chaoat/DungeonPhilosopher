local newArgument = function(name, level, energyCost, func, targets, image, spaceRequired, description)
	local okayTargets = {}
	for i = 1, #targets do
		local target = targets[i]
		local okayTarget = {range = math.ceil(target[1]), origin = target[2], aimType = target[3], description = target[4], orthogonal = false}
		if target[1] ~= okayTarget.range then
			okayTarget.orthogonal = true
		end
		table.insert(okayTargets, okayTarget)
	end
	local argument = {func = func, name = name, targets = okayTargets, energyCost = energyCost, description = description, image = image, spaceRequired = spaceRequired, level = level}
	return argument
end

local argumentBank = {}
local argumentsOfLevel = {}
local insertIntoArgumentBank = function(argument)
	if not argumentsOfLevel[argument.level] then
		argumentsOfLevel[argument.level] = {}
	end
	table.insert(argumentsOfLevel[argument.level], argument)
	argumentBank[argument.name] = argument
end

insertIntoArgumentBank(newArgument('Battlecry', -1, 0, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = math.floor(actor.x + math.cos(angle))
	local y = math.floor(actor.y + math.sin(angle))
	newThought(actor.parentMap.parentWorld, actor, x, y, angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(actor.x + math.cos(angle + math.pi/2)), roundNumber(actor.y + math.sin(angle + math.pi/2)), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(actor.x + math.cos(angle - math.pi/2)), roundNumber(actor.y + math.sin(angle - math.pi/2)), angle, 1, 1)
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 1,
'The naturally agressive ways of dungeon dwellers are made readily apparent.'))
insertIntoArgumentBank(newArgument('Stubbornness', -1, 0, function(targets, actor)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y, 0, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 1, math.pi/2, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, 3*math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y, math.pi, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, -3*math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 1, -math.pi/2, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, -math.pi/4, 0, 1)
end, {}, 'images/books/Scrap.png', 1,
"Years of stagnation have dealt their blow to this monster's mind."))
insertIntoArgumentBank(newArgument('Poignant reversal', -1, 0, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = math.cos(angle + math.pi/2)
	local upY = math.sin(angle + math.pi/2)
	local downX	= math.cos(angle - math.pi/2)
	local downY = math.sin(angle - math.pi/2)
	local forwardX = math.cos(angle)
	local forwardY = math.sin(angle)
	local backX = math.cos(angle + math.pi)
	local backY = math.sin(angle + math.pi)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + 2*forwardX), roundNumber(y + 2*forwardY), angle, 2, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + downX), roundNumber(y + forwardY + downY), angle, 2, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + 2*downX), roundNumber(y + 2*downY), angle, 2, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + upX), roundNumber(y + forwardY + upY), angle, 2, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + 2*upX), roundNumber(y + 2*upY), angle, 2, 0, {push = true})
end, {{0.5, 'actor', 'place', 'Select direction to create wall'}}, 'images/books/Scrap.png', 2,
"'How can you speak so when you yourself are not free from the crimes you condemn?'"))
insertIntoArgumentBank(newArgument('Brandish weapons', -1, 0, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = math.cos(angle + math.pi/2)
	local upY = math.sin(angle + math.pi/2)
	local downX	= math.cos(angle - math.pi/2)
	local downY = math.sin(angle - math.pi/2)
	local forwardX = math.cos(angle)
	local forwardY = math.sin(angle)
	local backX = math.cos(angle + math.pi)
	local backY = math.sin(angle + math.pi)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX), roundNumber(y + forwardY), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + downX), roundNumber(y + downY), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + upX), roundNumber(y + upY), angle, 1, 1)
	
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + 2*upX), roundNumber(y + forwardY + 2*upY), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + 2*downX), roundNumber(y + forwardY + 2*downY), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + backX + 2*upX), roundNumber(y + backY + 2*upY), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + backX + 2*downX), roundNumber(y + backY + 2*downY), angle, 1, 1)
end, {{0.5, 'actor', 'place', 'Select direction to create wall'}}, 'images/books/Scrap.png', 2,
"It's easy to see the agressive nature of monsters once you see the objects of their devotion."))
insertIntoArgumentBank(newArgument('Accuse humanphilia', -1, 0, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 2, 2)
end, {{2, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
'Nobody likes a human lover.'))
insertIntoArgumentBank(newArgument('Claim cowardice', -1, 0, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = math.cos(angle + math.pi/2)
	local upY = math.sin(angle + math.pi/2)
	local downX	= math.cos(angle - math.pi/2)
	local downY = math.sin(angle - math.pi/2)
	local forwardX = math.cos(angle)
	local forwardY = math.sin(angle)
	local backX = math.cos(angle + math.pi)
	local backY = math.sin(angle + math.pi)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + 2*forwardX + 2*upX), roundNumber(y + 2*forwardY + 2*upY), angle, 1, 1, {homing = true})
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + 2*forwardX + 2*downX), roundNumber(y + 2*forwardY + 2*downY), angle, 1, 1, {homing = true})
end, {{0.5, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
"'Only a coward would shy away from their duty to their dungeon.'"))
insertIntoArgumentBank(newArgument('Appeal to authority', -1, 0, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = math.cos(angle + math.pi/2)
	local upY = math.sin(angle + math.pi/2)
	local downX	= math.cos(angle - math.pi/2)
	local downY = math.sin(angle - math.pi/2)
	local forwardX = math.cos(angle)
	local forwardY = math.sin(angle)
	local backX = math.cos(angle + math.pi)
	local backY = math.sin(angle + math.pi)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX), roundNumber(y + forwardY), angle, 0, 2)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + downX), roundNumber(y + forwardY + downY), angle, 0, 2)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + upX), roundNumber(y + forwardY + upY), angle, 0, 2)
end, {{0.5, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
"'What would you know about killing, weakling?'"))
insertIntoArgumentBank(newArgument('Plea sunk cost', -1, 0, function(targets, actor)
	local x = actor.x
	local y = actor.y
	local orbit = {actor = actor, distance = 1, direction = -1}
	newThought(actor.parentMap.parentWorld, actor, x + 1, y, -math.pi/2, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x + 1, y + 1, -math.pi/2, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x, y + 1, 0, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x - 1, y + 1, 0, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x - 1, y, math.pi/2, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x - 1, y - 1, math.pi/2, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x, y - 1, math.pi, 2, 0, {orbit = orbit, push = true})
	newThought(actor.parentMap.parentWorld, actor, x + 1, y - 1, math.pi, 2, 0, {orbit = orbit, push = true})
end, {}, 'images/books/Scrap.png', 1,
"'So you seriously expect me to just throw out all these skulls?'"))
insertIntoArgumentBank(newArgument('Barely concealed agression', -1, 0, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle + math.pi/2))
	local upY = roundNumber(math.sin(angle + math.pi/2))
	local downX	= roundNumber(math.cos(angle - math.pi/2))
	local downY = roundNumber(math.sin(angle - math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + forwardX, y + forwardY, angle, 1, 2)
	newThought(actor.parentMap.parentWorld, actor, x + 2*forwardX, y + 2*forwardY, angle, 1, 2)
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
"'Why don't you come say that to my face?'"))
insertIntoArgumentBank(newArgument('Scoff and laugh', -1, 0, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle + math.pi/2))
	local upY = roundNumber(math.sin(angle + math.pi/2))
	local downX	= roundNumber(math.cos(angle - math.pi/2))
	local downY = roundNumber(math.sin(angle - math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + 2*upX, y + forwardY + 2*upY, angle, 3, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + upX, y + forwardY + upY, angle, 3, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX, y + forwardY, angle, 3, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + downX, y + forwardY + downY, angle, 3, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + 2*downX, y + forwardY + 2*downY, angle, 3, 0, {push = true})
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
"'A pacifist monster? I've never heard a more absurd notion in my life!'"))
insertIntoArgumentBank(newArgument("Absolute arrogance", -1, 2, function(targets, actor)
	for i = -2, 2 do
		for j = -2, 2 do
			if i ~= 0 or j ~= 0 then
				newThought(actor.parentMap.parentWorld, actor, actor.x + i, actor.y + j, 0, 0, 3)
			end
		end
	end
end, {}, 'images/books/Scrap.png', 2,
"YOUR PITIFUL ARGUMENTS CAN DO NOTHING AGAINST ARROGANCE OF THIS MAGNITUDE!"))
insertIntoArgumentBank(newArgument("Show off skulls", -1, 2, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle - math.pi/2))
	local upY = roundNumber(math.sin(angle - math.pi/2))
	local downX	= roundNumber(math.cos(angle + math.pi/2))
	local downY = roundNumber(math.sin(angle + math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + forwardX, y + forwardY, angle, 2, 2, {homing = true})
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 1,
"'These skulls are beautiful, are you seriously going to try and tell me they're not?'"))
insertIntoArgumentBank(newArgument("Gish gallop", -1, 2, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle - math.pi/2))
	local upY = roundNumber(math.sin(angle - math.pi/2))
	local downX	= roundNumber(math.cos(angle + math.pi/2))
	local downY = roundNumber(math.sin(angle + math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + 2*upX + backX, y + 2*upY + backY, angle, 1, 1, {homing = true})
	newThought(actor.parentMap.parentWorld, actor, x + upX, y + upY, angle, 1, 1, {homing = true})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX, y + forwardY, angle, 1, 1, {homing = true})
	newThought(actor.parentMap.parentWorld, actor, x + downX, y + downY, angle, 1, 1, {homing = true})
	newThought(actor.parentMap.parentWorld, actor, x + 2*downX + backX, y + 2*downY + backY, angle, 1, 1, {homing = true})
end, {{0.5, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
"'You're really not going to counter every single one of my hundred points?'"))
insertIntoArgumentBank(newArgument("Knuckle down", -1, 2, function(targets, actor)
	local x = targets[1][1]
	local y = targets[1][2]
	
	newThought(actor.parentMap.parentWorld, actor, x + 1, y, 0, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x + 1, y + 1, math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x, y + 1, math.pi/2, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x - 1, y + 1, 3*math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x - 1, y, math.pi, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x - 1, y - 1, -3*math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x, y - 1, -math.pi/2, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, x + 1, y - 1, -math.pi/4, 0, 1)
end, {{5, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 6,
"'I don't care whatever else we talk about, but you are going to answer this question!'"))
insertIntoArgumentBank(newArgument("Flat denial", -1, 2, function(targets, actor)
	local orbit1 = {actor = actor, distance = 1, direction = 1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, 0, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 1, 0, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, math.pi/2, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y, math.pi/2, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, math.pi, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 1, math.pi, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, -math.pi/2, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y, -math.pi/2, 1, 2, {orbit = orbit1})
end, {}, 'images/books/Scrap.png', 1,
"'What you're saying is ridiculous, I won't hear another word of it'"))
insertIntoArgumentBank(newArgument("Deny argumentation", -1, 2, function(targets, actor)
	for i = -2, 2 do
		for j = -2, 2 do
			if i ~= 0 or j ~= 0 then
				local angle = math.atan2(j, i)
				newThought(actor.parentMap.parentWorld, actor, actor.x + i, actor.y + j, angle, 2, 0, {push = true})
			end
		end
	end
end, {}, 'images/books/Scrap.png', 2,
"'What even are these fancy terms you are using. Who do you think you're convincing with such pretentious nonsense?'"))
insertIntoArgumentBank(newArgument('Call a goblin', -1, 2, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle + math.pi/2))
	local upY = roundNumber(math.sin(angle + math.pi/2))
	local downX	= roundNumber(math.cos(angle - math.pi/2))
	local downY = roundNumber(math.sin(angle - math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + 2*upX, y + forwardY + 2*upY, angle, 1, 3, {})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + upX, y + forwardY + upY, angle, 1, 3, {})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX, y + forwardY, angle, 1, 3, {})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + downX, y + forwardY + downY, angle, 1, 3, {})
	newThought(actor.parentMap.parentWorld, actor, x + forwardX + 2*downX, y + forwardY + 2*downY, angle, 1, 3, {})
end, {{0.5, 'actor', 'place', 'Select direction to create wall'}}, 'images/books/Scrap.png', 2,
"I can't believe a GOBLIN thinks he is in a position to convince me of anything!"))
insertIntoArgumentBank(newArgument("Threaten death", -1, 2, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle - math.pi/2))
	local upY = roundNumber(math.sin(angle - math.pi/2))
	local downX	= roundNumber(math.cos(angle + math.pi/2))
	local downY = roundNumber(math.sin(angle + math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + forwardX, y + forwardY, angle, 2, 3)
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 1,
"'Yeah better stop spouting this nonsense, or I will flay you head to toe.'"))
insertIntoArgumentBank(newArgument("Threaten torture", -1, 2, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	local x = actor.x
	local y = actor.y
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 2, 3)
end, {{3, 'actor', 'place', 'Select direction to send thought'}, {1, 'last', 'target', 'Select direction to send thought'}}, 'images/books/Scrap.png', 4,
"'You will scream for days before death finally welcomes you.'"))
insertIntoArgumentBank(newArgument("Macabre display", -1, 2, function(targets, actor)
	local orbit1 = {actor = actor, distance = 1, direction = 1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, 0, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 1, 0, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, math.pi/2, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y, math.pi/2, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, math.pi, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 1, math.pi, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, -math.pi/2, 1, 3, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y, -math.pi/2, 1, 3, {orbit = orbit1})
	
	local orbit2 = {actor = actor, distance = 2, direction = -1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y - 2, math.pi, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y - 2, -math.pi/2, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y + 2, 0, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y + 2, math.pi/2, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y, math.pi/2, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y, -math.pi/2, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 2, 0, 1, 3, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 2, math.pi, 1, 3, {orbit = orbit2})
end, {}, 'images/books/Scrap.png', 2,
"'Even if I were to agree with you, it would be far too late for me to follow your path. Better I love who I am than hate who I was.'"))
insertIntoArgumentBank(newArgument("Shame ancestry", -1, 2, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	local x = actor.x
	local y = actor.y
	
	local upX = roundNumber(math.cos(angle - math.pi/2))
	local upY = roundNumber(math.sin(angle - math.pi/2))
	local downX	= roundNumber(math.cos(angle + math.pi/2))
	local downY = roundNumber(math.sin(angle + math.pi/2))
	local forwardX = roundNumber(math.cos(angle))
	local forwardY = roundNumber(math.sin(angle))
	local backX = roundNumber(math.cos(angle + math.pi))
	local backY = roundNumber(math.sin(angle + math.pi))
	newThought(actor.parentMap.parentWorld, actor, x + 3*forwardX, y + 3*forwardY, angle, 4, 3, {homing = true})
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 3,
"'Your father was a killer, and so was his father before him, going back to the dawn of goblin kind. Now you stand here before me, a traitor to your people and your blood.'"))

insertIntoArgumentBank(newArgument('Loud yelling', 0, 0, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 1, 1)
end, {{1, 'actor', 'place', 'Select direction to send thought'}}, 'images/books/Scrap.png', 1,
'An ancient technique preserved from generation to generation as the fundamental action of all dungeon dwelling arguments.'))
insertIntoArgumentBank(newArgument('Cunning insult', 0, 1, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 1, 1)
end, {{1, 'actor', 'place', 'Select location to create thought'}, {1, 'last', 'target', 'Select direction to send thought'}}, 'images/books/Scrap.png', 2,
'Many dungeon denizens have some deformity, physical or otherwise, which can be taken advantage of for the purpose of argument.'))
insertIntoArgumentBank(newArgument('Point & yell', 0, -1, function(targets, actor)
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], 0, 0, 1)
end, {{1, 'actor', 'place', 'Select location to create thought'}}, 'images/books/Scrap.png', 1,
'A distraction tactic commonly used to create space to breathe in an argument.'))
insertIntoArgumentBank(newArgument('Pretend listening', 0, 1, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 1, 0, {push = true})
end, {{1, 'actor', 'place', 'Select location to create thought'}}, 'images/books/Scrap.png', 1,
"Accidentally losing focus happens all the time in a debate, especially when it's not accidental."))
insertIntoArgumentBank(newArgument('Hurtful mockery', 0, 2, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = math.floor(actor.x + math.cos(angle))
	local y = math.floor(actor.y + math.sin(angle))
	newThought(actor.parentMap.parentWorld, actor, x, y, angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + math.cos(angle + math.pi/2)), roundNumber(y + math.sin(angle + math.pi/2)), angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + math.cos(angle - math.pi/2)), roundNumber(y + math.sin(angle - math.pi/2)), angle, 1, 1)
end, {{0.5, 'actor', 'place', 'Select direction to create wall'}}, 'images/books/Scrap.png', 1,
"A masterful tactic devised many centuries ago by leading goblin philosophers."))

insertIntoArgumentBank(newArgument("The Flurp gambit", 1, 2, function(targets, actor)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y, 0, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, math.pi/4, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 1, math.pi/2, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, 3*math.pi/4, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y, math.pi, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, -3*math.pi/4, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 1, -math.pi/2, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, -math.pi/4, 1, 1)
end, {}, 'images/books/Scrap.png', 1,
"The famous goblin philosopher Flurp was renowned to never have lost an argument, mostly due to his tendency to cover his ears and scream before his opponent could get in a single word."))
insertIntoArgumentBank(newArgument("Snorble's principle", 1, 1, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	local pX = actor.x
	local pY = actor.y
	for i = 1, 2 do
		local aX, aY = findTileAtAngle(angle)
		pX = pX + aX
		pY = pY + aY
		newThought(actor.parentMap.parentWorld, actor, pX, pY, angle, 1, 1)
	end
end, {{1, 'actor', 'place', 'Select direction to send thoughts'}}, 'images/books/Scrap.png', 2,
"Snorble's principle is as follows, 'If one does not have enough force for the task at hand, one needs more force'. This principle was instrumental to the goblins defeat of the human invaders in 645, as their strategy up to that point had consisted at looking at things larger than them and running in the opposite direction."))
insertIntoArgumentBank(newArgument('On the essential force of freedom', 1, 4, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	newThought(actor.parentMap.parentWorld, actor, targets[2][1], targets[2][2], angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, targets[3][1], targets[3][2], angle, 1, 1)
	newThought(actor.parentMap.parentWorld, actor, targets[4][1], targets[4][2], angle, 1, 1)
end, {{1, 'actor', 'target', 'Select direction to send thoughts'}, {2, 'actor', 'place', 'Select location to create thought(1)'}, {2, 'actor', 'place', 'Select location to create thought(2)'}, {2, 'actor', 'place', 'Select location to create thought(3)'}}, 'images/books/Scrap.png', 2,
"Putrescence Snotflinger describes with breathtaking clarity the essential force of freedom that underlines and nurtures all life. He explains how it is not only a crime of the highest level to remove another beings freedom, but that it is also literally impossible."))
insertIntoArgumentBank(newArgument("Vlad's impunity", 1, 3, function(targets, actor)
	local orbit1 = {actor = actor, distance = 1, direction = -1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, math.pi, 2, 1, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, -math.pi/2, 2, 1, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, 0, 2, 1, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, math.pi/2, 2, 1, {orbit = orbit1})
end, {}, 'images/books/Scrap.png', 1,
'A beautifully written novel by Beatrice the Impaler that tells the tale of a young vampire who forsook the drinking of human blood.'))
insertIntoArgumentBank(newArgument("The right to life", 1, -1, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	newThought(actor.parentMap.parentWorld, actor, targets[1][1] - 1, targets[1][2], angle, 1, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2] - 1, angle, 1, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, targets[1][1] + 1, targets[1][2], angle, 1, 0, {push = true})
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2] + 1, angle, 1, 0, {push = true})
end, {{2, 'actor', 'place', 'Select location to create thoughts'}, {1, 'last', 'target', 'Select direction for thoughts'}}, 'images/books/Scrap.png', 3,
"A detailed essay by Burble Thump arguing for a right to life for all beings."))
insertIntoArgumentBank(newArgument("Calm listening", 1, -2, function(targets, actor)
	local angle = math.atan2(actor.y - targets[1][2], actor.x - targets[1][1])
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 2, 0, {push = true})
end, {{2, 'actor', 'place', 'Select location to create thoughts'}}, 'images/books/Scrap.png', 2,
"Take a moment to listen to your opponents argument."))
insertIntoArgumentBank(newArgument('Zone out', 1, -3, function(targets, actor)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y, 0, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 1, math.pi/2, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, 3*math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y, math.pi, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, -3*math.pi/4, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 1, -math.pi/2, 0, 1)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, -math.pi/4, 0, 1)
end, {}, 'images/books/Scrap.png', 1,
"Ignore some of your opponents arguments, in the hope that they won't come back to them."))

insertIntoArgumentBank(newArgument('Iron as a material of peace', 2, 3, function(targets, actor)
	local orbit1 = {actor = actor, distance = 1, direction = 1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y - 1, 0, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y - 1, math.pi/2, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 1, actor.y + 1, math.pi, 1, 2, {orbit = orbit1})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 1, actor.y + 1, -math.pi/2, 1, 2, {orbit = orbit1})
	
	local orbit2 = {actor = actor, distance = 2, direction = -1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y - 2, math.pi, 2, 2, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y - 2, -math.pi/2, 2, 2, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y + 2, 0, 2, 2, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y + 2, math.pi/2, 2, 2, {orbit = orbit2})
end, {}, 'images/books/Scrap.png', 2,
'Axe Butch discusses in this essay the myriad uses of iron, arguing against the commonly held belief that its only use is for cracking skulls.'))
insertIntoArgumentBank(newArgument('The duality of man', 2, 3, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = actor.x
	local y = actor.y
	
	local upX = math.cos(angle - math.pi/2)
	local upY = math.sin(angle - math.pi/2)
	local downX	= math.cos(angle + math.pi/2)
	local downY = math.sin(angle + math.pi/2)
	local forwardX = math.cos(angle)
	local forwardY = math.sin(angle)
	local backX = math.cos(angle + math.pi)
	local backY = math.sin(angle + math.pi)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX), roundNumber(y + forwardY), angle, 1, 2)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + downX), roundNumber(y + downY), angle + math.pi/2, 1, 2)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + upX), roundNumber(y + upY), angle - math.pi/2, 1, 2)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + downX), roundNumber(y + forwardY + downY), angle + math.pi/4, 1, 2)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + forwardX + upX), roundNumber(y + forwardY + upY), angle - math.pi/4, 1, 2)
end, {{0.5, 'actor', 'place', 'Select direction to send thoughts'}}, 'images/books/Scrap.png', 1,
"This essay reveals the beastial core present within all men, a core not so different from that found within monsters."))
insertIntoArgumentBank(newArgument("Queblec's division", 2, -4, function(targets, actor)
	local speed = 2
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y, math.pi, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y + 2, -3*math.pi/4, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y + 2, -math.pi/2, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y + 2, -math.pi/4, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y, 0, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y - 2, math.pi/4, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x, actor.y - 2, math.pi/2, speed, 0)
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y - 2, 3*math.pi/4, speed, 0)
end, {}, 'images/books/Scrap.png', 2,
"This article explores in great detail the difference between humans and monsters, and is filled with thick use jargon and terminology. When used correctly, your opponent will be so confused they'll be lost for words, but most of the time you'll just end up looking like a fool."))
insertIntoArgumentBank(newArgument("The meat eaters menace", 2, 3, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 1, 2)
	newThought(actor.parentMap.parentWorld, actor, targets[2][1], targets[2][2], angle, 1, 2)
end, {{2, 'actor', 'place', 'Place base of line'}, {1, 'last', 'place', 'Place head of line'}}, 'images/books/Scrap.png', 3,
"This essay goes into detail on the health benefits of eating plants, and warns against the dangers present to any monster that feasts only on human flesh."))
insertIntoArgumentBank(newArgument("Easy skull replacements", 2, 2, function(targets, actor)
	local angle = math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x)
	local pX = actor.x
	local pY = actor.y
	for i = 1, 2 do
		local aX, aY = findTileAtAngle(angle)
		pX = pX + aX
		pY = pY + aY
		if i == 1 then
			newThought(actor.parentMap.parentWorld, actor, pX, pY, angle, 2, 2)
		elseif i == 2 then
			newThought(actor.parentMap.parentWorld, actor, pX, pY, angle, 2, 0, {push = true})
		end
	end
end, {{1, 'actor', 'place', 'Select direction to send thoughts'}}, 'images/books/Scrap.png', 2,
"This book describes a number of different objects that make good replacements for skulls in decorations. The book is surprisingly long, ranging all the way from coconuts to giant snail shells."))
insertIntoArgumentBank(newArgument('Reiterate axioms', 2, -1, function(targets, actor)
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], 0, 0, 3)
end, {{2, 'actor', 'place', 'Select location to create thought'}}, 'images/books/Scrap.png', 2,
'It is often necessary to return back to previous points in the argument and lay them bare, to assure that you are not talking past your opponent.'))

insertIntoArgumentBank(newArgument('Story of a monster raised human', 3, 7, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 3, 3)
end, {{2, 'actor', 'place', 'Select location to create thought'}, {1, 'last', 'target', 'Select direction to send thought'}}, 'images/books/Scrap.png', 3,
'The heartbreaking tale of a human boy raised in a dungeon, and the struggles he faced while coming to terms with his split identity.'))
insertIntoArgumentBank(newArgument('Relate personal experience', 2, -4, function(targets, actor)
	local orbit2 = {actor = actor, distance = 2, direction = -1}
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y - 2, math.pi, 3, 1, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y - 2, -math.pi/2, 3, 1, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x + 2, actor.y + 2, 0, 3, 1, {orbit = orbit2})
	newThought(actor.parentMap.parentWorld, actor, actor.x - 2, actor.y + 2, math.pi/2, 3, 1, {orbit = orbit2})
end, {}, 'images/books/Scrap.png', 2,
'You know, I used to be a killer just like you, murdering just to get by.'))
insertIntoArgumentBank(newArgument("Reveal tragic life story", 3, -1, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	for i = -1, 1 do
		for j = -1, 1 do
			if i == 0 and j == 0 then
				newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 2, 1)
			else
				newThought(actor.parentMap.parentWorld, actor, targets[1][1] + i, targets[1][2] + j, angle, 2, 0, {push = true})
			end
		end
	end
end, {{2, 'actor', 'place', 'Select placement location'}, {1, 'last', 'target', 'Select direction for thoughts'}}, 'images/books/Scrap.png', 3,
"Explain how when you were a child, you were found and cared for by humans for a brief period."))
insertIntoArgumentBank(newArgument("Speegle's argument for peace", 3, 4, function(targets, actor)
	local angle = orthogonalizeAngle(math.atan2(targets[1][2] - actor.y, targets[1][1] - actor.x))
	local x = math.floor(actor.x + math.cos(angle))
	local y = math.floor(actor.y + math.sin(angle))
	newThought(actor.parentMap.parentWorld, actor, x, y, angle, 1, 3)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + math.cos(angle + math.pi/2)), roundNumber(y + math.sin(angle + math.pi/2)), angle, 1, 3)
	newThought(actor.parentMap.parentWorld, actor, roundNumber(x + math.cos(angle - math.pi/2)), roundNumber(y + math.sin(angle - math.pi/2)), angle, 1, 3)
end, {{0.5, 'actor', 'place', 'Select direction to create wall'}}, 'images/books/Scrap.png', 1,
"This short yet superbly structured essay is better than anything you ever could have come up with. There is a pristine clarity to the argument that makes it complex, yet understandable, and the examples used throughout are nigh uncounterable. It is simply sublime."))
insertIntoArgumentBank(newArgument('Perfect deflection', 3, -2, function(targets, actor)
	local angle = math.atan2(targets[2][2] - targets[1][2], targets[2][1] - targets[1][1])
	newThought(actor.parentMap.parentWorld, actor, targets[1][1], targets[1][2], angle, 3, 0, {push = true})
end, {{1, 'actor', 'place', 'Select location to create thought'}, {1, 'last', 'target', 'Select direction to send thought'}}, 'images/books/Scrap.png', 4,
'Contained within this text is the key to dealing with any argument too solid to be confronted directly.'))


function getArgument(argumentName)
	return argumentBank[argumentName]
end

function getArgumentsOfLevel(level)
	local argumentList = {}
	for i = 1, #argumentsOfLevel[level] do
		table.insert(argumentList, argumentsOfLevel[level][i])
	end
	return argumentList
end

function useArgument(argument, actor)
	argument.func({}, actor)
end

function targetArgument(x, y, targets, argument, actor)
	if checkArgumentFits(x, y, targets, argument, actor) then
		table.insert(targets, {x, y})
		if #targets == #argument.targets then
			return true
		end
		return false
	end
	return false
end

function checkArgumentFits(x, y, targets, argument, actor)
	local nextTarget = argument.targets[#targets + 1]
	if nextTarget.aimType == 'place' then
		if not checkThoughtFits(actor.parentMap, x, y) then
			return false
		end
		local mapTile = getTile(actor.parentMap, x, y)
		if mapTile.actor then
			return false
		end
		for i = 1, #targets do
			if argument.targets[i].aimType == 'place' then
				if targets[i][1] == x and targets[i][2] == y then
					return false
				end
			end
		end
	elseif nextTarget.aimType == 'target' then
		if nextTarget.origin == 'actor' then
			if x == actor.x and y == actor.y then
				return false
			end
		elseif nextTarget.origin == 'last' then
			if x == targets[#targets][1] and y == targets[#targets][2] then
				return false
			end
		end
	end
	return true
end