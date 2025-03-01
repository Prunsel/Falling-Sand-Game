-- Sand
stone = {
    properties = {
        name  = "sand", 
        colour = {r = 1, g = 0.9, b = 0.5, a = 1},
        noise = true,
        check = true,
        type = "solid",
        density = 2,
        corrosive_res = 0.3,
        integrity = 0.4
    },

    update = function(cell)
        if cell.element.properties.density > down.element.properties.density and down.checked == false and down.element.properties.type ~= "solid" then
            swapCells(cell, down) -- Falling
    
        elseif love.math.random(0, 100) > cell.element.properties.integrity * 100 and cell.isFalling and cell.element.properties.density > down_left.element.properties.density and cell.element.properties.density > left.element.properties.density then
            swapCells(cell, down_left) -- Diagonal left movement
    
        elseif love.math.random(0, 100) > cell.element.properties.integrity * 100 and cell.isFalling and cell.element.properties.density > down_right.element.properties.density and cell.element.properties.density > right.element.properties.density then
            swapCells(cell, down_right) -- Diagonal right movement
    
        end
    end
}

return stone