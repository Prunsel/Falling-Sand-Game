
-- Water
water = {

    -- Element properties
    properties = {
        name  = "water",
        colour = {r = 0.25, g = 0.68, b = 0.85, a = 0.4},
        check = true,
        type = "liquid",
        density = 1,
        corrosive_res = 0.2,
        dispersion_rate = 20,
    },
    
    -- Water update
    update = function(cell, grid, x, y)

        if down and cell.element.properties.density > down.element.properties.density and not down.checked then
            swapCells(cell, down) -- Falling
    
        else
            local goLeft = math.random(0, 1)

            if goLeft == 0 then
                if left and cell.element.properties.density > left.element.properties.density and not left.checked then
                    swapCells(cell, left) -- Left
                end

            else
                if right and cell.element.properties.density > right.element.properties.density and not right.checked then
                    swapCells(cell, right) -- Right
                end
                
            end
        end

    end,
    
}

return water