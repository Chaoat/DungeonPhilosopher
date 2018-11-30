require 'terrain'
require 'imageLib'
require 'mapGeneration'
require 'genFunctions'
require 'vision'
require 'actors'
require 'worlds'
require 'player'
require 'turnCalculation'
require 'thoughts'
require 'arguments'
require 'books'
require 'messageLog'
require 'enemies'
require 'interface'
require 'enemyGeneration'
require 'particles'

function love.load()
	love.keyboard.setKeyRepeat(true)
	math.randomseed(os.clock())
	love.window.setMode(800, 600, {resizable = true, minwidth = 800, minheight = 600})
	loadFonts()
	testArray = {}
	
	debugSettings = {showThoughtTiles = false, enableTutorial = true, allowPlayerDeath = true, lastTurn = 0}
	
	innitiateLevelList()
	
	startGame()

	--testMap = newMap(11, 11, 'unFilled', 'images/tiles/baseTile.png')
	--testRooms = {}
	--testEntrances = {}
	
	--generateRoom(testMap, testRooms, testEntrances)
	--generateRoom(testMap, testRooms, testEntrances)
end

function loadFonts()
	Fonts = {}
	Fonts.bookDisplayFont = love.graphics.newFont('fonts/Hack-Regular.ttf', 12)
	Fonts.nameFont = love.graphics.newFont('fonts/Hack-Regular.ttf', 20)
end

function startGame()
	cameraX = 0
	cameraY = 0
	
	innitiateMessageLog()
	Particles = innitiateParticleSystem()
	Player = innitiatePlayer()
	loadLevel(1)
	activateTutorial('start', {-150, -250})
end

function love.update(dt)
	updateParticles(Particles, dt)
	if Player.dead then
		autoTurns(dt)
	end
end

function autoTurns(dt)
	if debugSettings.lastTurn - dt > 0 then
		debugSettings.lastTurn = debugSettings.lastTurn - dt
	else
		debugSettings.lastTurn = 0.1
		processTurn(Player.currentWorld)
	end
end

function love.keypressed(key)
	checkPlayerInput(Player, key)
	
	if key == 'f5' then
		debugSettings.showThoughtTiles = flipBoolean(debugSettings.showThoughtTiles)
	elseif key == 'f6' then
		debugSettings.allowPlayerDeath = flipBoolean(debugSettings.allowPlayerDeath)
	end
end

function moveCamera(dt)
	local cameraMoveSpeed = 10
	if love.keyboard.isDown('up') then
		cameraY = cameraY - dt*cameraMoveSpeed
	end
	if love.keyboard.isDown('down') then
		cameraY = cameraY + dt*cameraMoveSpeed
	end
	if love.keyboard.isDown('left') then
		cameraX = cameraX - dt*cameraMoveSpeed
	end
	if love.keyboard.isDown('right') then
		cameraX = cameraX + dt*cameraMoveSpeed
	end
end

function love.draw()
	drawWorld(World, 44, 44)
	drawOverWorldInterface(Player)
	if debugSettings.enableTutorial then
		drawTutorials(44, 44)
	end
	drawEndText()
	
	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #testArray do
		love.graphics.print(testArray[i], 0, (i - 1)*14)
	end
end