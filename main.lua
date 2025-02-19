-- Falling Sand Game


-- Require libraries
anim8 = require "libraries.anim8"
moonshine = require "libraries.moonshine"

-- Require scripts
player = require "scripts.player"
sand = require "scripts.element_handler"

-- Removes sprite blur
love.graphics.setDefaultFilter("nearest", "nearest")

--------------------------------------------------------------------------



-- Load
function love.load()

    -- Set window dimensions
    --love.window.setMode(600, 400)

    -- Get window dimensions
    window_width, window_height = love.window.getMode()

    -- Get font
    love.graphics.newFont("assets/fonts/CrimsonText-Bold.ttf")

    -- Camera table
    camera = {
        x = 0,
        y = 0
    }
    
    -- Mouse table
    mouse = {
        x = 0,
        y = 0,
        left = false,
        right = false,
        middle = false
    }
    
    -- Initialize grid
    grid_init()
    
    -- FPS Variable
    fps = 0

    -- Draw mode
    draw_mode = "brush"
    draw_mode_swap = false

    -- Default brush radius
    brush_radius = 5

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
    
    -- Mouse update
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.left = love.mouse.isDown(1)
    mouse.right = love.mouse.isDown(2)
    mouse.middle = love.mouse.isDown(3)

    -- Swap drawing brush
    if love.keyboard.isDown("q") then
        draw_mode = "pixel" -- Pixel draw

    elseif love.keyboard.isDown("e") then
        draw_mode = "brush" -- Brush draw

    end
    
    -- Change selected material
    if love.keyboard.isDown("1") then
        material = element.sand

    elseif love.keyboard.isDown("2") then
        material = element.indestructible

    elseif love.keyboard.isDown("3") then
        material = element.water

    elseif love.keyboard.isDown("4") then
        material = element.acid

    elseif love.keyboard.isDown("5") then
        material = element.acid_gas

    elseif love.keyboard.isDown("6") then
        material = element.soil

    elseif love.keyboard.isDown("7") then
        material = element.stone

    elseif love.keyboard.isDown("8") then
        material = element.steam

    elseif love.keyboard.isDown("9") then
        material = element.lava

    end

    -- Pausing
    if love.keyboard.isDown("p") then
        paused = true
    elseif love.keyboard.isDown("o") then
        paused = false
    end


    -- Grid update
    grid_update(dt)

end ----------------------------------------------------------------------



-- Draw
function love.draw()

    -- Translate coordinates
    love.graphics.translate(camera.x, camera.y)

    -- Draw background
    love.graphics.draw(backgrounds.cave, 0, 0, 0, window_width / backgrounds.cave:getWidth(), window_height / backgrounds.cave:getHeight())

    -- Draw grid
    grid_draw()

    -- Display selected material
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Material : "..material.name, 5, 3)

    -- Display the simulation speed
    love.graphics.print("Simulation speed : "..simulation_speed, 5, 18)

    -- Display FPS
    love.graphics.print("Current FPS : "..fps, 5, 33)

    -- Display draw mode
    love.graphics.print("Draw mode : "..draw_mode, 5, 48)

    -- Display if the game is paused or not
    if paused then
        love.graphics.print("Paused", window_width / 2 - 25, 3)
    end

end -----------------------------------------------------------------------







-- Detect mouse on cells
function isTouchingMouse(x, y)
    if mouse.x >= x and mouse.x <= x + cell_size and mouse.y >= y and mouse.y <= y + cell_size then
        return true
    else
        return false
    end
end



-- Detect mouse distance to cell
function isNearMouse(x, y)
    if distance(mouse.x, mouse.y, x + cell_size / 2, y + cell_size / 2) <= brush_radius * cell_size then
        return true
    else
        return false
    end
end



-- Screen shake
function screen_shake(intensity)
    -- Resets camera
    camera.x, camera.y = 0, 0

    -- Moves camera randomly
    camera.x = love.math.random(-intensity, intensity)
    camera.y = love.math.random(-intensity, intensity)
end



-- Calculate distance between two positions
function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end



-- Finds out if a value is in a table
function isInTable(value, table)
    for i = 1, #table do

        local this_value = table[i]
        if value == this_value then
            return true
        end

    end
    return false

end