-- Falling Sand Game


-- Require libraries
anim8 = require "libraries.anim8"
moonshine = require "libraries.moonshine"

-- Removes sprite blur
love.graphics.setDefaultFilter("nearest", "nearest")

--------------------------------------------------------------------------



-- Load
function love.load()

    -- Set window dimensions
    love.window.setMode(600, 400)

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
    

    -- Grid of cells
    grid = {}
    cell_size = 8
    
    -- Elements
    element = {
        empty = {name  = "empty", colour = {r = 0, g = 0, b = 0}, physics = "void", density = 0.3, corrosive_res = 1},
        indestructible = {name  = "indestructible", colour = {r = 0.2, g = 0.2, b = 0.2}, physics = "static", density = 9, corrosive_res = 1},
        wall = {name  = "wall", colour = {r = 0.1, g= 0.1, b= 0.1}, physics = "static", density = 8, corrosive_res = 1},
        sand = {name  = "sand", colour = {r = 1, g = 0.9, b = 0.5, a = 1}, noise = true, physics = "powder", density = 1, corrosive_res = 0.2, integrity = 0.3},
        water = {name = "water", colour = {r = 0.15, g = 0.7, b = 0.8, a = 0.3}, physics = "liquid", density = 0.5, corrosive_res = 0.1, gas = "steam"},
        steam = {name = "steam", colour = {r = 0.15, g = 0.7, b = 0.8, a = 0.1}, physics = "gas", density = 0.1, corrosive_res = 0.1, liquid = "water", condense_time = 300},
        acid = {name = "acid", colour = {r = 0, g = 0.8, b = 0, a = 0.4}, bloom = true, physics = "liquid", density = 0.4, corrosive_res = 1, corrosiveness = 0.4, gas = "acid_gas"},
        acid_gas = {name = "acid_gas", colour = {r = 0, g = 0.8, b = 0, a = 0.1}, physics = "gas", density = 0.1, corrosive_res = 1, corrosiveness = 0.4, liquid = "acid", condense_time = 600},
        soil = {name = "soil", colour = {r = 0.45, g = 0.25, b = 0, a = 1}, noise = true, physics = "powder", density = 1.2, corrosive_res = 0.2, integrity = 0.5},
        stone = {name = "stone", colour = {r = 0.3, g = 0.3, b = 0.3, a = 1}, noise = true, physics = "static", density = 2, corrosive_res = 0.35}
    }

    -- Initalize grid
    for i = -1, window_width / cell_size do
        grid[i] = {}
        for j = -1, window_height / cell_size do

            -- Makes cell
            grid[i][j] = {
                x = (i - 1) * cell_size, 
                y = (j - 1) * cell_size,
                xv = 0,
                yv = 0,
                checked = false,
                isFalling = true,
                lifetime = 0
            }

            -- If cell is at the edge it becomes the wall element and if it is not then become empty
            if grid[i][j].x == 0 or grid[i][j].x == window_width - cell_size or grid[i][j].y == 0 or grid[i][j].y == window_height - cell_size then
                grid[i][j].properties = element.wall
            else
                grid[i][j].properties = element.empty
            end
            
        end
    end

    -- Cell neighbours
    down = 0
    down_left = 0
    down_right = 0
    left = 0
    right = 0
    up = 0
    up_left = 0
    up_right = 0

    -- Default selected material
    material = element.sand

    -- Pause variable
    paused = false

    -- Default simulation speed
    simulation_speed = 0.01

    -- Counter to update simulation everytime it reaches the simulation speed
    simulation_count = 0

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

    end

    -- Pausing
    if love.keyboard.isDown("p") then
        paused = true
    elseif love.keyboard.isDown("o") then
        paused = false
    end

    -- Simulation count increment
    simulation_count = simulation_count + dt

    -- Grid update
    if simulation_count >= simulation_speed then
        grid_update()
        simulation_count = simulation_count - simulation_speed
    end

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



-- Update grid
function grid_update()

    -- Uncheck all cells
    for x = 1, window_width / cell_size do
        for y = 1, window_height / cell_size do
            grid[x][y].checked = false
        end
    end

    -- Update cells
    for x = 1, window_width / cell_size do
        for y = window_height / cell_size, 1, -1 do

            -- Get current cell
            this_cell = grid[x][y]

            -- Get cell neighboursx
            if this_cell.properties.name ~= "wall" or this_cell.checked then    
                down = grid[x][y + 1]
                down_left = grid[x - 1][y + 1]
                down_right = grid[x + 1][y + 1]
                left = grid[x - 1][y]
                right = grid[x + 1][y]
                up = grid[x][y - 1]
                up_left = grid[x - 1][y - 1]
                up_right = grid[x + 1][y - 1]
            end

            -- Drawing and erasing
            if this_cell.properties.name ~= "wall" and draw_mode == "pixel" then -- Pixel drawing
                if isTouchingMouse(this_cell.x, this_cell.y) then
                    if mouse.left then
                        this_cell.properties = material
                    elseif mouse.right then
                        this_cell.properties = element.empty
                        this_cell.checked = true
                    end
                end

            elseif this_cell.properties.name ~= "wall" and draw_mode == "brush" then -- Brush drawing (Circle)
                if isNearMouse(this_cell.x, this_cell.y) then
                    if mouse.left then
                        this_cell.properties = material
                    elseif mouse.right then
                        this_cell.properties = element.empty
                        this_cell.checked = true
                    end
                end

            end

            -- Cell update
            if not this_cell.checked and not paused then
                cellUpdate(this_cell)
            end
            
        end ---------------------------------------------------------------------------
    end 

end -----------------------------------------------------------------------------------



-- Draws grid
function grid_draw()

    for i = 1, window_width / cell_size do
        for j = 1, window_height / cell_size do

            local cell = grid[i][j]
            
            -- Set cell color with noise for sand
            if cell.properties.noise then
                local noise = love.math.noise(cell.x * 0.1, cell.y * 0.1)
                local r = cell.properties.colour.r * (0.9 + 0.1 * noise)
                local g = cell.properties.colour.g * (0.9 + 0.1 * noise)
                local b = cell.properties.colour.b * (0.9 + 0.1 * noise)
                love.graphics.setColor(r, g, b, cell.properties.colour.a)
            else
                love.graphics.setColor(cell.properties.colour.r, cell.properties.colour.g, cell.properties.colour.b, cell.properties.colour.a)
            end
            
            -- Draw cell
            if cell.properties.name ~= "empty" then
                love.graphics.rectangle("fill", cell.x, cell.y, cell_size, cell_size)
            end

        end
    end

end ----------------------------------------------------------------------------------



-- Element Behaviours
function cellUpdate(cell)

    if cell.properties.physics == "powder" then
        powder(cell)
        cell.lifetime = cell.lifetime + 1
    elseif cell.properties.physics == "liquid" then
        liquid(cell)
        cell.lifetime = cell.lifetime + 1
    elseif cell.properties.physics == "gas" then
        gas(cell)
        cell.lifetime = cell.lifetime + 1
    end

end ----------------------------------------------------------------------------------------------



-- Powder behaviour
function powder(cell)

    if cell.properties.density > down.properties.density and down.checked == false then
        swapCells(cell, down) -- Falling

    elseif love.math.random(0, 100) > cell.properties.integrity * 100 and cell.isFalling and cell.properties.density > down_left.properties.density and cell.properties.density > left.properties.density then
        swapCells(cell, down_left) -- Diagonal left movement

    elseif love.math.random(0, 100) > cell.properties.integrity * 100 and cell.isFalling and cell.properties.density > down_right.properties.density and cell.properties.density > right.properties.density then
        swapCells(cell, down_right) -- Diangonal right movement

    end

end ---------------------------------------------------------------------------------------------



-- Liquid behaviour
function liquid(cell)
    
    if corrodeCheck(cell, down) then -- Corroding
        replaceCells(down, cell, cell.properties.gas)

    elseif cell.properties.density > down.properties.density and not down.checked then -- Falling
        swapCells(cell, down)

    else -- Moving left and right

        local goLeft = love.math.random(0, 1) -- Randomly picks whether or not the cell goes left or right

        if goLeft == 1 then -- Left

            if corrodeCheck(cell, left) then
                replaceCells(cell, left)
                
            elseif cell.properties.density > left.properties.density and left.properties.name == "empty" and not left.checked then
                swapCells(cell, left)
                
            end
                
            
        elseif goLeft == 0 then -- Right
            
            if corrodeCheck(cell, right) then
                replaceCells(cell, right)
                
            elseif cell.properties.density > right.properties.density and right.properties.name == "empty" and not right.checked then
                swapCells(cell, right)
                
            end
                
            
        end

    end

end ---------------------------------------------------------------------------------------------------------------------------------



-- Gas behaviour
function gas(cell)

    if corrodeCheck(cell, up) then -- Corroding
        replaceCells(cell, up)

    elseif cell.properties.density < up.properties.density and up.properties.physics ~= "static" and not up.checked then -- Rising
        swapCells(cell, up)

    else -- Moving left and right

        local goLeft = love.math.random(0, 1) -- Randomly picks whether or not the cell goes left or right

        if goLeft == 1 then -- Left

            if corrodeCheck(cell, left) then
                replaceCells(cell, left)
                
            elseif cell.properties.density < left.properties.density and left.properties.name == "empty" then
                swapCells(cell, left)
                
            end
            
        elseif goLeft == 0 then -- Right
            
            if corrodeCheck(cell, right) then
                replaceCells(cell, right)
                
            elseif cell.properties.density < right.properties.density and right.properties.name == "empty" then
                swapCells(cell, right)
                
            end
            
        end

    end

    -- Condensing
    if cell.properties.condense_time and cell.lifetime >= cell.properties.condense_time then
        setCell(cell, cell.properties.liquid)
    end

end ---------------------------------------------------------------------------------------------------------------------------------



-- Corrosion check
function corrodeCheck(cell, cell2)
    if cell.properties.corrosiveness and love.math.random(0, 100) < (cell.properties.corrosiveness * 100) - (cell2.properties.corrosive_res * 100) then
        return true
    else
        return false
    end
end



-- Set cell
function setCell(cell, element_name)
    cell.properties = element[element_name]
    cell.checked = true
    cell.lifetime = 0
end



-- Swap cells
function swapCells(cell1, cell2)
    local new_properties = cell2.properties

    cell2.properties = cell1.properties
    cell2.checked = true
    cell2.lifetime = cell1.lifetime
    cell1.properties = new_properties
    cell1.checked = true
    cell1.lifetime = cell2.lifetime
    
end



-- Replace cell
function replaceCells(cell1, cell2, byproduct)
    local new_properties = cell2.properties

    cell2.properties = cell1.properties
    cell2.checked = true
    if byproduct then
        cell1.properties = element[byproduct]
        cell1.lifetime = 0
    else
        cell1.properties = element.empty
        cell1.lifetime = 0
    end
    cell1.checked = true
end



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