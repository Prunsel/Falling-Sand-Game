
-- Fire
fire = {

    -- Element properties
    properties = {
        name  = "fire",
        colour = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
        check = true,
        type = "gas",
        density = 0.31,
        corrosive_res = 1,
    },
    
    
    update = function(cell)
        
        if cell.lifetime > 1000 and love.math.random() > 0.99 then
            setCell(cell, element.empty)
        
        elseif corrodeCheck(cell, up) then
            replaceCells(cell, up)

        elseif up and cell.element.properties.density < up.element.properties.density and up.element.properties.type ~= "solid" and not up.checked then
            swapCells(cell, up)

        else
            local goLeft = math.random(0, 1)
            if goLeft == 0 then

                if left and cell.element.properties.density < left.element.properties.density and not left.checked then
                    if corrodeCheck(cell, left) then
                        replaceCells(cell, left)
                    elseif left.element.properties.type ~= "solid" then
                        swapCells(cell, left)
                    end
                end

            else

                if right and cell.element.properties.density < right.element.properties.density and not right.checked then
                    if corrodeCheck(cell, right) then
                        replaceCells(cell, right)
                    elseif right.element.properties.type ~= "solid" then
                        swapCells(cell, right)
                    end
                end

            end
        end

    end,
    
}

return fire