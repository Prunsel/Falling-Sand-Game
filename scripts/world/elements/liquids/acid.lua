
-- Acid
acid = {

    -- Element properties
    properties = {
        name  = "acid",
        colour = {r = 0, g = 0.8, b = 0, a = 0.4},
        check = true,
        type = "liquid",
        density = 0.4,
        corrosive_res = 1,
        corrosiveness = 0.4,
        gas = "acid_gas"
    },
    
    
    update = function(cell)
        
        if corrodeCheck(cell, down) then
            replaceCells(cell, down)
            screen_shake(1)
        elseif down and cell.element.properties.density > down.element.properties.density and not down.checked then
            swapCells(cell, down)

        else
            local goLeft = math.random(0, 1)
            if goLeft == 0 then

                if left and cell.element.properties.density > left.element.properties.density and not left.checked then
                    if corrodeCheck(cell, left) then
                        replaceCells(cell, left)
                        screen_shake(1)
                    else
                        swapCells(cell, left)
                    end
                end

            else

                if right and cell.element.properties.density > right.element.properties.density and not right.checked then
                    if corrodeCheck(cell, right) then
                        replaceCells(cell, right)
                        screen_shake(1)
                    else
                        swapCells(cell, right)
                    end
                end

            end
        end

    end,
    
}

return acid