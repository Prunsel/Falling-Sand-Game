
-- Sand
sand = {

    properties = {
        name  = "sand",
        colour = {r = 1, g = 0.9, b = 0.5, a = 1},
        noise = true,
        density = 1,
        corrosive_res = 0.2,
        integrity = 0.3
    },
    
    -- Sand update
    update = function(cell)

        if down and cell.element.properties.density > down.element.properties.density and not down.checked then
            swapCells(cell, down) -- Falling
    
        elseif down_left and left and love.math.random(0, 100) > cell.element.properties.integrity * 100 and cell.isFalling and cell.element.properties.density > down_left.element.properties.density and cell.element.properties.density > left.element.properties.density then
            swapCells(cell, down_left) -- Diagonal left movement
    
        elseif down_right and right and love.math.random(0, 100) > cell.element.properties.integrity * 100 and cell.isFalling and cell.element.properties.density > down_right.element.properties.density and cell.element.properties.density > right.element.properties.density then
            swapCells(cell, down_right) -- Diagonal right movement
    
        end

    end,
    
}

return sand