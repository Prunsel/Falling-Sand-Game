-- Falling Sand Game


-- Require libraries
anim8 = require "libraries.anim8"
moonshine = require "libraries.moonshine"

-- Require scripts
sandfall = require "libraries.sandfall.sandfall"

-- Removes sprite blur
love.graphics.setDefaultFilter("nearest", "nearest")

--------------------------------------------------------------------------



-- Load
function love.load()

    -- Set window dimensions
    love.window.setMode(600, 400)

    -- Get window dimensions
    window_width, window_height = love.window.getMode()

    -- Get fonts
    font = love.graphics.newFont("assets/fonts/Quicksand-Regular.ttf")
    crimson = love.graphics.newFont("assets/fonts/CrimsonText-Bold.ttf")
    love.graphics.setFont(font)

    -- Camera table
    camera = {
        x = 0,
        y = 0
    }
    
    -- Initialize grid
    grid_init()
    
    -- FPS Variable
    fps = 0

    -- Backgrounds
    backgrounds = {
        cave = love.graphics.newImage("assets/sprites/backgrounds/cave.png"),
        test = love.graphics.newImage("assets/sprites/backgrounds/test.png"),
    }

end ----------------------------------------------------------------------



-- Update
function love.update(dt)

    -- Get FPS
    fps = love.timer.getFPS()
    
    
    -- Grid update
    grid_update(dt)

end ----------------------------------------------------------------------



-- Draw
function love.draw()

    -- Translate coordinates
    love.graphics.translate(camera.x, camera.y)

    -- Draw background
    love.graphics.draw(backgrounds.test, 0, 0, 0, window_width / backgrounds.cave:getWidth(), window_height / backgrounds.cave:getHeight())

    -- Draw grid
    grid_draw()

    -- Display if the game is paused or not
    love.graphics.setColor(1, 1, 1)
    if paused then
        love.graphics.print("Paused", window_width / 2 - 25, 3)
    end

    -- Displaey FPS
    love.graphics.print("FPS: " .. fps, 3, 3)

end -----------------------------------------------------------------------



-- Screen shake
function screen_shake(intensity)
    -- Resets camera
    camera.x, camera.y = 0, 0

    -- Moves camera randomly
    camera.x = love.math.random(-intensity, intensity)
    camera.y = love.math.random(-intensity, intensity)
end