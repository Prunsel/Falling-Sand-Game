
-- Handles elements
sand = {}

-- Load grid and variables
function grid_init()
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
        steam = {name = "steam", colour = {r = 0.15, g = 0.7, b = 0.8, a = 0.1}, physics = "gas", density = 0.1, corrosive_res = 0.1, liquid = "water", condense_time = 5000},
        acid = {name = "acid", colour = {r = 0, g = 0.8, b = 0, a = 0.4}, physics = "liquid", density = 0.4, corrosive_res = 1, corrosiveness = 0.4, gas = "acid_gas"},
        acid_gas = {name = "acid_gas", colour = {r = 0, g = 0.8, b = 0, a = 0.1}, physics = "gas", density = 0.1, corrosive_res = 1, corrosiveness = 0.4, liquid = "acid", condense_time = 6000},
        soil = {name = "soil", colour = {r = 0.45, g = 0.25, b = 0, a = 1}, noise = true, physics = "powder", density = 1.2, corrosive_res = 0.2, integrity = 0.5},
        stone = {name = "stone", colour = {r = 0.3, g = 0.3, b = 0.3, a = 1}, noise = true, physics = "static", density = 10, corrosive_res = 0.35, liquid = "lava"},
	    lava = {name = "lava", colour = {r = 1, g = 0.4, b = 0, a = 1}, physics = "liquid", density = 4, corrosive_res = 10, corrosiveness = 0.02, solid = "stone", solidify_time = 600}
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
    down_right = 07
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

end



-- Update grid
function grid_update(dt)
    if simulation_count >= simulation_speed then
            -- Reset camera
        camera.x, camera.y = 0, 0

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

            end
            
        end
        
        -- Reset simulation counter
        simulation_count = simulation_count - simulation_speed 
            
    end -----------------------------------------------------------------------------------

    -- Simulation count increment
    simulation_count = simulation_count + dt
    
end --------------------------------------------------------------------------------------

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

    cell2.properties = element.empty
    cell2.lifetime = 0
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

return sand