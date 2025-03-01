-- Falling Sand Game


-- Require libraries
anim8 = require "libraries.anim8"
moonshine = require "libraries.moonshine"
world = require "scripts.world.material_manager"

-- Removes sprite blur
love.graphics.setDefaultFilter("nearest", "nearest")

--------------------------------------------------------------------------



-- Load
function love.load()

    -- Set window dimensions
    love.window.setFullscreen(true)

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

    -- Camera speed
    if love.keyboard.isDown("lshift") then
        cam.speed = 11
    else
        cam.speed = 5
    end

    -- Camera movement
    if love.keyboard.isDown("w") then
        cam.y = cam.y + cam.speed
    end
    if love.keyboard.isDown("s") then
        cam.y = cam.y - cam.speed
    end
    if love.keyboard.isDown("d") then
        cam.x = cam.x - cam.speed
    end
    if love.keyboard.isDown("a") then
        cam.x = cam.x + cam.speed
    end
    camera.x, camera.y = cam.x, cam.y

end ----------------------------------------------------------------------



-- Draw
function love.draw()

    -- Translate coordinates
    love.graphics.translate(camera.x, camera.y)
    
    -- Draw grid
    grid_draw()

    -- Display if the game is paused or not
    love.graphics.setColor(1, 1, 1)
    if paused then
        love.graphics.print("Paused", window_width / 2 - 25 - camera.x, 3 - camera.y)
    end

    -- Display FPS
    love.graphics.print("FPS: " .. fps, 3 - camera.x, 3 - camera.y)
    
    -- Display selected material
    love.graphics.print("Material: " ..material.properties.name, 3 - camera.x, 15 - camera.y)

end -----------------------------------------------------------------------


