
-- Player script

-- Require libraries
require "libraries/anim8"

-- Require main
--require "main"

player = {
	x = 0,
	y = 0,
	xv = 0,
	yv = 0,
	health = 100,
	health_max = 100,
}

-- Initialize player
function player:init()

	body = love.physics.newBody(world, 5, 5, "dynamic")
	shape = love.physics.newRectangleShape(32, 32)
	fixture = love.physics.newFixture(body, shape) 

end



-- Player update
function player:update()

end



-- Player draw
function player:draw()

	-- Draw player
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", player.x, player.y, 32, 32)

end

return player