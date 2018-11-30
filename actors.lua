function newActor(baseSprite)
	local actor = {x = nil, y = nil, baseSprite = loadImage(baseSprite), facing = 1, parentMap = nil, orbitingThoughts = {}, controller = nil}
	return actor
end

function moveActorInDirection(actor, xDir, yDir)
	if moveActor(actor.parentMap, actor, actor.x + xDir, actor.y + yDir) then
		local i = 1
		while i <= #actor.orbitingThoughts do
			local thought = actor.orbitingThoughts[i]
			if not thought.dead then
				moveThought(thought, xDir, yDir, {})
				i = i + 1
			else
				table.remove(actor.orbitingThoughts, i)
			end
		end
	end
end

function moveActor(map, actor, x, y)
	local oTile = getTile(map, actor.x, actor.y)
	local dTile = getTile(map, x, y)
	if checkProperties(dTile, {blocksWalker = false}) and dTile.thought == nil then
		if dTile.actor == nil then
			if oTile then
				oTile.actor = nil
				
				if getVisionTile(World.visionMap, oTile.x, oTile.y) == 1 then
					newParticle(oTile.x, oTile.y, true, 0, 0, {kind = 'image', image = actor.baseSprite, angle = 0, sX = actor.facing, sY = 1}, {0.1, 0.1, 0.1, 0.4}, 1, 0)
				end
				if actor.x < x then
					actor.facing = 1
				elseif actor.x > x then
					actor.facing = -1
				end
			end
			
			dTile.actor = actor
			actor.x = x
			actor.y = y
			actor.parentMap = map
			return true
		elseif oTile then
			local angleToCollision = math.atan2(dTile.y - oTile.y, dTile.x - oTile.x)
			local xBump, yBump = findTileAtAngle(angleToCollision)
			moveActorInDirection(dTile.actor, xBump, yBump)
		end
	end
	return false
end

function checkActorThoughtCollisions(actors, map, thoughts)
	for i = 1, #actors do
		local actor = actors[i]
		local tile = getTile(map, actor.x, actor.y)
		if tile.thought then
			local thought = tile.thought
			if thought.power > 0 then
				if actor.controller.enemy and not tile.thought.hostile then
					if actor.controller.inCombat then
						convinceEnemy(actor.controller)
					else
						agroEnemy(actor.controller)
					end
				elseif not actor.controller.enemy then
					damagePlayer(actor.controller, 1)
				end
			end
			thought.dead = true
		end
	end
	clearOutDeadThoughts(thoughts)
end

function drawActors(actors, visionMap, xOffset, yOffset, tileW, tileH)
	for i = 1, #actors do
		local actor = actors[i]
		if getVisionTile(visionMap, actor.x, actor.y) >= 1 then
			local drawX = math.ceil(actor.x*tileW + xOffset)
			local drawY = math.ceil(actor.y*tileH + yOffset)
			drawActor(actor, drawX, drawY, tileW, tileH)
			
			if actor.controller.enemy then
				activateTutorial('enemies', actor)
				if actor.controller.king then
					activateTutorial('king', actor)
				end
			end
		end
	end
end

function drawActor(actor, x, y, tileW, tileH)
	love.graphics.setColor(1, 1, 1, 1)
	local sX = tileW/actor.baseSprite.width
	local sY = tileH/actor.baseSprite.height
	
	if actor.facing == -1 then
		sX = -sX
	end
	
	love.graphics.draw(actor.baseSprite.image, x, y, 0, sX, sY, math.ceil(actor.baseSprite.width/2), math.ceil(actor.baseSprite.height/2))
	if playerControlHeld(Player, 'viewLastTurn') then
		if actor.controller.enemy then
			local enemy = actor.controller
			if enemy.activity == 'wandering' then
				local angle = math.atan2(enemy.targetY - enemy.actor.y, enemy.targetX - enemy.actor.x)
				love.graphics.setColor(0, 0, 0, 1)
				
				local tX, tY = findTileAtAngle(angle)
				angle = math.atan2(tY, tX)
				
				local lineLength = math.sqrt(tileW^2 + tileH^2)/2
				local lineEX = x + lineLength*tX
				local lineEY = y + lineLength*tY
				love.graphics.line(x, y, lineEX, lineEY)
				love.graphics.line(lineEX, lineEY, lineEX + (lineLength/4)*math.cos(angle + 3*math.pi/4), lineEY + (lineLength/4)*math.sin(angle + 3*math.pi/4))
				love.graphics.line(lineEX, lineEY, lineEX + (lineLength/4)*math.cos(angle - 3*math.pi/4), lineEY + (lineLength/4)*math.sin(angle - 3*math.pi/4))
			end
		end
	end
end