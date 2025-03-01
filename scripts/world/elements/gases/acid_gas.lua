
-- Acid gas
acid_gas = {

    -- Element properties
    properties = {
        name  = "acid_gas",
        colour = {r = 0, g = 0.7, b = 0, a = 0.3},
        check = true,
        type = "gas",
        density = 0.4,
        corrosive_res = 1,
        corrosiveness = 0.41,
        liquid = acid,
    },
    
    
    update = function(cell)
        
        if cell.lifetime > 400 then
            setCell(cell, cell.element.properties.liquid)
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

    end
    
}

return acid_gas