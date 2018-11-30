local imageLibrary = {}
local tileImages = {}

function loadImage(dir)
	if dir == nil then
		return {image = nil, width = 0, height = 0}
	end
	
	if not imageLibrary[dir] then
		local image = love.graphics.newImage(dir)
		imageLibrary[dir] = {image = image, width = image:getWidth(), height = image:getHeight()}
		imageLibrary[dir].image:setFilter('nearest', 'nearest')
	end
	return imageLibrary[dir]
end

function getImage(dir)
	local image = loadImage(dir)
	return image.image
end

function getImageDimensions(dir)
	local image = loadImage(dir)
	return image.width, image.height
end

function innitiateTileQuads(dir)
	local images = {}
	local image = love.graphics.newImage(dir)
	local imageX = 266
	local imageY = 442
	
	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, 6 do
		images[i] = {}
		for j = 1, 10 do
			local quad = love.graphics.newQuad(1 + 44*(i - 1), 1 + 44*(j - 1), 44, 44, imageX, imageY)
			local tileCanvas = love.graphics.newCanvas(44, 44)
			love.graphics.setCanvas(tileCanvas)
			love.graphics.draw(image, quad, 0, 0)
			love.graphics.setCanvas()
			images[i][j] = {image = tileCanvas, width = 44, height = 44}
		end
	end
	return images
end

function loadTileImage(i, j, dir)
	if not tileImages[dir] then
		tileImages[dir] = innitiateTileQuads(dir)
	end
	return tileImages[dir][i][j]
end