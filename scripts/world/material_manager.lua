
-- Require behaviours
require "scripts.world.elements.behaviours"

-- Handles elements
world = {}

-- Load grid and variables
function grid_init()
    -- Get window dimensions
    window_width, window_height = love.window.getMode()
    
    -- Grid of cells
    grid = {}
    cell_size = 10
    water_height = 100

    -- Elements
    element = { -- Add elements here  \/ Filepaths \/ 
        empty = require "scripts.world.elements.other.empty",
        wall = require "scripts.world.elements.other.wall",
        water = require "scripts.world.elements.liquids.water",
        stone = require "scripts.world.elements.solids.stone",
        compressed_stone = require "scripts.world.elements.solids.compressed_stone",
        indestructible = require "scripts.world.elements.solids.indestructible",
        player = require "scripts.player",
        acid = require "scripts.world.elements.liquids.acid",
        acid_gas = require "scripts.world.elements.gases.acid_gas",
        sand = require "scripts.world.elements.powders.sand",
        fire = require "scripts.world.elements.gases.fire",
        smoke = require "scripts.world.elements.gases.smoke"
    }
    
    -- World seed
    seed = love.math.random(0, 100000)

    -- Initialize grid
    local grid_width = 300
    local grid_height = 300

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

            -- World generation
            if i == 0 or i == grid_width or j == 0 or j == grid_height then
                grid[i][j].element = element.wall
            else
                local noise_value = 0
                local frequency = 0.001
                local amplitude = 0.6
                local persistence = 0.6
                local octaves = 4

                for o = 1, octaves do
                    noise_value = noise_value + love.math.noise(seed, grid[i][j].x * frequency, grid[i][j].y * frequency) * amplitude
                    frequency = frequency * 1.6
                    amplitude = amplitude * persistence
                end

                if noise_value > 0.7 then
                    grid[i][j].element = element.compressed_stone
                elseif noise_value > 0.64 then
                    grid[i][j].element = element.stone
                elseif grid[i][j].y > (grid_height - water_height) * cell_size then
                    grid[i][j].element = element.water
                elseif grid[i][j].y == (grid_height - water_height) * cell_size and love.math.random() > 0.4 then
                    grid[i][j].element = element.water
                else
                    grid[i][j].element = element.empty
                end
            end
        end
    end

    -- Post-processing step to remove small isolated bits of stone
    clean_up_stone(grid, grid_width, grid_height)

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
    
end

-- Count neighboring stone cells
function count_neighboring_stone(grid, x, y)
    local count = 0
    local neighbors = {
        {x = x - 1, y = y - 1},
        {x = x, y = y - 1},
        {x = x + 1, y = y - 1},
        {x = x - 1, y = y},
        {x = x + 1, y = y},
        {x = x - 1, y = y + 1},
        {x = x, y = y + 1},
        {x = x + 1, y = y + 1}
    }

    for _, neighbor in ipairs(neighbors) do
        if grid[neighbor.x] and grid[neighbor.x][neighbor.y] and (grid[neighbor.x][neighbor.y].element == element.stone or grid[neighbor.x][neighbor.y].element == element.compressed_stone) then
            count = count + 1
        end
    end

    return count
end

-- Clean up small isolated bits of stone
function clean_up_stone(grid, grid_width, grid_height)
    for i = 1, grid_width - 1 do
        for j = 1, grid_height - 1 do
            if grid[i][j].element == element.stone or grid[i][j].element == element.compressed_stone then
                local neighboring_stone_count = count_neighboring_stone(grid, i, j)
                if neighboring_stone_count < 4 then
                    grid[i][j].element = element.empty
                end
            end
        end
    end
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
    elseif love.keyboard.isDown("7") then
        material = element.acid_gas
    elseif love.keyboard.isDown("8") then
        material = element.fire
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

                elseif cell.element.properties.noise_chaos then
                    local noise = love.math.noise(cell.x * love.math.random(), cell.y * love.math.random())
                    local r, g, b

                    if noise < 0.5 then
                        r = 1.0
                        g = noise * 2.0
                        b = 0.0
                    else
                        r = 1.0
                        g = 1.0
                        b = (noise - 0.5) * 1.5
                    end

                    local brightness = 0.5 + 0.5 * noise
                    r = r * brightness
                    g = g * brightness
                    b = b * brightness

                    love.graphics.setColor(r, g, b, cell.element.properties.colour.a)

                else

                    love.graphics.setColor(cell.element.properties.colour.r, cell.element.properties.colour.g, cell.element.properties.colour.b, cell.element.properties.colour.a)
                end
                
                if cell.element.properties.name ~= "empty" then
                    love.graphics.rectangle("fill", cell.x, cell.y, cell_size, cell_size)
                end

            end
        end
    end

end

-- Corrosion check
function corrodeCheck(cell, cell2)
    if cell.element.properties.corrosiveness and love.math.random(0, 100) < (cell.element.properties.corrosiveness * 100) - (cell2.element.properties.corrosive_res * 100) then
        return true
    else
        return false
    end
end



-- Cell reaction
function reactCells(cell1, cell2, product)
    
    cell1.element = element[product]
    cell1.checked = true
    cell1.lifetime = 0

    cell2.element = empty
    cell2.checked = true
    cell2.lifetime = 0
end



-- Set cell
function setCell(cell, element)
    cell.element = element
    cell.checked = true
    cell.lifetime = 0
end



-- Swap cells
function swapCells(cell1, cell2)
    local new_element = cell2.element

    cell2.element = cell1.element
    cell2.checked = true
    cell2.lifetime = cell1.lifetime
    
    cell1.element = new_element
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

-- Freeze check
function freezeCheck(cell)
    if up.element.properties.freeze then
        return true
    elseif up_left.element.properties.freeze then
        return true
    elseif up_right.element.properties.freeze then
        return true
    elseif left.element.properties.freeze then
        return true
    elseif right.element.properties.freeze then
        return true
    elseif down.element.properties.freeze then
        return true
    elseif down_left.element.properties.freeze then
        return true
    elseif down_right.element.properties.freeze then
        return true
    else
        return false
    end
end

-- Condense cell
function condense(cell)
    setCell(cell, cell.element.properties.liquid)
end

-- Melt cell
function melt(cell)
    setCell(cell, cell.element.properties.liquid)
end

-- Solidify cell
function solidify(cell)
    setCell(cell, cell.element.properties.solid)
end

-- Burn check
function burnCheck(cell)
    if up.element.properties.burn then
        return true
    elseif up_left.element.properties.burn then
        return true
    elseif up_right.element.properties.burn then
        return true
    elseif left.element.properties.burn then
        return true
    elseif right.element.properties.burn then
        return true
    elseif down.element.properties.burn then
        return true
    elseif down_left.element.properties.burn then
        return true
    elseif down_right.element.properties.burn then
        return true
    else
        return false
    end
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