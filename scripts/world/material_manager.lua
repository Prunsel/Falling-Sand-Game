-- Handles elements
world = {}

-- Load grid and variables
function grid_init()
    -- Get window dimensions
    window_width, window_height = love.window.getMode()
    
    -- Grid of cells
    grid = {}
    cell_size = 8
    water_height = 2

    -- Elements
    element = { -- Add elements here  \/ Filepaths \/ 
        empty = require "scripts.world.elements.other.empty",
        wall = require "scripts.world.elements.other.wall",
        water = require "scripts.world.elements.liquids.water",
        stone = require "scripts.world.elements.solids.stone",
        indestructible = require "scripts.world.elements.solids.indestructible",
        player = require "scripts.player",
        acid = require "scripts.world.elements.liquids.acid",
        sand = require "scripts.world.elements.powders.sand"
    }
    
    -- Initialize grid
    local grid_width = 200
    local grid_height = 500

    for i = 0, grid_width do
        grid[i] = {}
        for j = 0, grid_height do
            -- Makes cell 
            grid[i][j] = {
                x = i * cell_size, 
                y = j * cell_size,
                checked = false,
                isFalling = true,
                lifetime = 0
            }

            -- If cell is at the edge it becomes the wall element and if it is not then become empty
            if i == 0 or i == grid_width or j == 0 or j == grid_height then
                grid[i][j].element = element.wall
            elseif love.math.noise(grid[i][j].x * 0.001, grid[i][j].y * 0.001) - 0.1 > 0.5 then
                grid[i][j].element = element.stone
            elseif grid[i][j].y < (water_height) * cell_size then
                grid[i][j].element = element.water
            elseif grid[i][j].y == water_height * cell_size and love.math.random() > 0.4 then
                grid[i][j].element = element.water
            else
                grid[i][j].element = element.empty
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

    -- Counter to update simulation every time it reaches the simulation speed
    simulation_count = 0

    -- Draw mode
    draw_mode = "brush"
    draw_mode_swap = false

    -- Default brush radius
    brush_radius = 5

    -- Mouse table
    mouse = {
        x = 0,
        y = 0,
        left = false,
        right = false,
        middle = false
    }

    -- Another camera table
    cam = {}
    cam.x, cam.y = 0, 0

    -- Pixel sprite
    pixel = love.graphics.newImage("assets/sprites/pixel.png")
    
end

-- Update grid
function grid_update(dt)
    -- Pausing
    if love.keyboard.isDown("p") then
        paused = true
    elseif love.keyboard.isDown("o") then
        paused = false
    end

    -- Mouse update
    mouse.x = love.mouse.getX() - camera.x
    mouse.y = love.mouse.getY() - camera.y
    mouse.left = love.mouse.isDown(1)
    mouse.right = love.mouse.isDown(2)
    mouse.middle = love.mouse.isDown(3)

    -- Swap drawing brush
    if love.keyboard.isDown("q") then
        draw_mode = "pixel" -- Pixel draw
    elseif love.keyboard.isDown("e") then
        draw_mode = "brush" -- Brush draw
    end

    -- Element swap
    if love.keyboard.isDown("1") then
        material = element.sand
    elseif love.keyboard.isDown("2") then
        material = element.indestructible
    elseif love.keyboard.isDown("3") then
        material = element.stone
    elseif love.keyboard.isDown("4") then
        material = element.water
    elseif love.keyboard.isDown("5") then
        material = element.acid
    elseif love.keyboard.isDown("6") then
        material = element.player
    end

    -- Update 
    if simulation_count >= simulation_speed then
        -- Reset camera
        camera.x, camera.y = 0, 0

        -- Uncheck all cells
        for x = 1, #grid do
            for y = 1, #grid[1] do
                grid[x][y].checked = false
            end
        end

        -- Update cells
        for x = 1, #grid do
            for y = #grid[1], 1, -1 do
                -- Get current cell
                local this_cell = grid[x][y]

                -- Get cell neighbours
                if this_cell.element.properties.name ~= "wall" then
                    down = grid[x][y + 1]
                    down_left = grid[x - 1][y + 1]
                    down_right = grid[x + 1][y + 1]
                    left = grid[x - 1][y]
                    right = grid[x + 1][y]
                    up = grid[x][y - 1]
                    up_left = grid[x - 1][y - 1]
                    up_right = grid[x + 1][y - 1]
                end

                -- Update cell
                if (not this_cell.checked) and (not paused) and (this_cell.element.properties.check) then
                    this_cell.element.update(this_cell, grid, x, y)
                end

                -- Drawing and erasing
                if this_cell.element.properties.name ~= "wall" then
                    if draw_mode == "pixel" and isTouchingMouse(this_cell.x, this_cell.y) then
                        if mouse.left then
                            this_cell.element = material
                        elseif mouse.right then
                            this_cell.element = element.empty
                            this_cell.checked = true
                        end
                    elseif draw_mode == "brush" and isNearMouse(this_cell.x, this_cell.y) then
                        if mouse.left then
                            this_cell.element = material
                        elseif mouse.right then
                            this_cell.element = element.empty
                            this_cell.checked = true
                        end
                    end
                end

                -- Increase lifetime
                this_cell.lifetime = this_cell.lifetime + 1
            end
        end

        -- Reset simulation counter
        simulation_count = simulation_count - simulation_speed
    end

    -- Simulation count increment
    simulation_count = simulation_count + dt
end

-- Draws grid
function grid_draw()

    for i = 0, #grid do
        for j = 0, #grid[1] do
            local cell = grid[i][j]
            
            -- Check if the cell is within the visible area
            if cell.x >= -camera.x - cell_size and cell.x <= -camera.x + window_width + cell_size and cell.y >= -camera.y - cell_size and cell.y <= -camera.y + window_height + cell_size then
                if cell.element.properties.noise then
                    local noise = love.math.noise(cell.x * 0.1, cell.y * 0.1)
                    local r = cell.element.properties.colour.r * (0.9 + 0.1 * noise)
                    local g = cell.element.properties.colour.g * (0.9 + 0.1 * noise)
                    local b = cell.element.properties.colour.b * (0.9 + 0.1 * noise)
                    love.graphics.setColor(r, g, b, cell.element.properties.colour.a)
                else
                    love.graphics.setColor(cell.element.properties.colour.r, cell.element.properties.colour.g, cell.element.properties.colour.b, cell.element.properties.colour.a)
                end
                
                -- Add cell to sprite batch
                if cell.element.properties.name ~= "empty" then
                    love.graphics.rectangle("fill", cell.x, cell.y, cell_size, cell_size)
                end
            end
        end
    end

end



-- Powder behaviour
function powder(cell)

    if cell.properties.density > down.properties.density and down.checked == false and down.properties.physics ~= "static" then
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
        replaceCells(cell, down, cell.properties.gas)
        screen_shake(1)
    elseif cell.properties.density > down.properties.density and down.properties.physics ~= "static" and not down.checked then -- Falling
        swapCells(cell, down)

    else -- Moving left and right

        local goLeft = love.math.random(0, 1) -- Randomly picks whether or not the cell goes left or right

        if goLeft == 1 then -- Left

            if corrodeCheck(cell, left) then
                replaceCells(cell, left, cell.properties.gas)
                screen_shake(1)
            elseif cell.properties.density > left.properties.density and not left.checked then
                swapCells(cell, left)
                
            end
                
            
        elseif goLeft == 0 then -- Right
            
            if corrodeCheck(cell, right) then
                replaceCells(cell, right, cell.properties.gas)
                screen_shake(1)
            elseif cell.properties.density > right.properties.density and not right.checked then
                swapCells(cell, right)
                
            end
                
            
        end

    end

    -- Solidifying
    if cell.properties.solidify_time and cell.lifetime >= cell.properties.solidify_time then
        setCell(cell, cell.properties.solid)
    end

end ---------------------------------------------------------------------------------------------------------------------------------



-- Gas behaviour
function gas(cell)

    if corrodeCheck(cell, up) then -- Corroding
        replaceCells(cell, up)
        screen_shake(1)
    elseif cell.properties.density < up.properties.density and up.properties.physics ~= "static" and not up.checked then -- Rising
        swapCells(cell, up)

    else -- Moving left and right

        local goLeft = love.math.random(0, 1) -- Randomly picks whether or not the cell goes left or right

        if goLeft == 1 then -- Left

            if corrodeCheck(cell, left) then
                replaceCells(cell, left)
                screen_shake(1)
            elseif cell.properties.density < left.properties.density and left.properties.name == "empty" then
                swapCells(cell, left)
                
            end
            
        elseif goLeft == 0 then -- Right
            
            if corrodeCheck(cell, right) then
                replaceCells(cell, right)
                screen_shake(1)
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
    if cell.element.properties.corrosiveness and love.math.random(0, 100) < (cell.element.properties.corrosiveness * 100) - (cell2.element.properties.corrosive_res * 100) then
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
    local new_element = cell2.element

    cell2.element = cell1.element
    cell2.checked = true
    cell2.lifetime = cell1.lifetime
    
    cell1.element= new_element
    cell1.checked = true
    cell1.lifetime = cell2.lifetime
    
end



-- Replace cell
function replaceCells(cell1, cell2)
    local new_element = cell2.element

    cell2.element = element.empty
    cell2.lifetime = 0
    cell2.checked = true
    cell1.element = element.empty
    cell1.lifetime = 0
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

-- Calculate distance between two positions
function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- Screen shake
function screen_shake(intensity)
    -- Resets camera
    camera.x, camera.y = 0, 0

    -- Moves camera randomly
    camera.x = love.math.random(-intensity, intensity)
    camera.y = love.math.random(-intensity, intensity)
end

return world
