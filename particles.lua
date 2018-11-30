function innitiateParticleSystem()
	return {particles = {}}
end

function newParticle(x, y, mapBound, direction, speed, drawObject, colour, fade, lifeTime, properties)
	if not properties then
		properties = {}
	end
	local particle = {x = x, y = y, mapBound = mapBound, direction = direction, speed = speed, drawObject = drawObject, colour = colour, fade = fade, lifeTime = lifeTime}
	for key, value in pairs(properties) do
		particle[key] = value
	end
	
	table.insert(Particles.particles, particle)
	return particle
end

function updateParticles(particles, dt)
	local i = 1
	while i <= #particles.particles do
		local particle = particles.particles[i]
		
		particle.x = particle.x + dt*particle.speed*math.cos(particle.direction)
		particle.y = particle.y + dt*particle.speed*math.sin(particle.direction)
		
		if particle.accelerate then
			particle.speed = particle.speed + dt*particle.accelerate
		end
		
		particle.colour[4] = particle.colour[4] - dt*particle.fade
		if particle.lifeTime > 0 then
			if particle.lifeTime - dt > 0 then
				particle.lifetime = particle.lifeTime - dt
			else
				particle.lifeTime = -1
			end
		end
		if particle.colour[4] <= 0 or particle.lifeTime < 0 then
			table.remove(particles.particles, i)
		else
			i = i + 1
		end
	end
end

function imageBurst(x, y, size, fade, image, n)
	for i = 1, n do
		local posX = x + plusOrMinus()*math.random()*size
		local posY = y + plusOrMinus()*math.random()*size
		
		local speed = math.random()
		newParticle(posX, posY, true, -math.pi/2, speed, image, {1, 1, 1, 1}, fade, 0, {accelerate = -speed*fade})
	end
end

function drawParticles(particles, xOffset, yOffset, tileW, tileH)
	for i = 1, #particles.particles do
		local particle = particles.particles[i]
		drawParticle(particle, xOffset, yOffset, tileW, tileH)
	end
end

function drawParticle(particle, xOffset, yOffset, tileW, tileH)
	local drawX = math.ceil(particle.x)
	local drawY = math.ceil(particle.y)
	local sX = 1
	local sY = 1
	if particle.mapBound then
		drawX = math.ceil(particle.x*tileW + xOffset)
		drawY = math.ceil(particle.y*tileH + yOffset)
		sX = tileW/44
		sY = tileH/44
	end
	
	love.graphics.setColor(particle.colour)
	if particle.drawObject.kind == 'image' then
		local image = particle.drawObject.image
		love.graphics.draw(image.image, drawX, drawY, particle.drawObject.angle, particle.drawObject.sX*sX, particle.drawObject.sY*sY, image.width/2, image.height/2)
	elseif particle.drawObject.kind == 'rect' then
		local xSize = particle.drawObject.xSize*sX
		local ySize = particle.drawObject.ySize*sY
		love.graphics.rectangle('fill', drawX - xSize/2, drawY - ySize/2, xSize, ySize)
	elseif particle.drawObject.kind == 'circle' then
		local radius = particle.drawObject.radius*math.min(sX, sY)
		love.graphics.circle('fill', drawX, drawY, radius)
	end
end