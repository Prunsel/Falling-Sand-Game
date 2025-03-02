
-- Behaviours for cells


-- Solid
function solid(cell)
    if cell.element.properties.melts and burnCheck() then
        melt(cell)

    elseif cell.element.properties.flammability and burnCheck() then
        if cell.element.properties.flammability > love.math.random() then
            if love.math.random() > 0.3 then
                setCell(cell, "fire")
            elseif cell.element.properties.ashes then
                setCell(cell, "ash")
            end
            
        end
    end

end

-- Powder
function powder(cell)

    if cell.element.properties.melts and burnCheck() then
        melt(cell)

    elseif cell.element.properties.flammability and burnCheck() then
        if cell.element.properties.flammability > love.math.random() then
            setCell(cell, "fire")
        elseif cell.element.properties.ashes then
            setCell(cell, "ash")
        end
    
    elseif cell.element.properties.density > down.element.properties.density and down.checked == false and down.element.properties.type ~= "solid" then
        swapCells(cell, down) -- Falling

    elseif love.math.random(0, 100) > cell.element.properties.integrity * 100 and cell.isFalling and cell.element.properties.density > down_left.element.properties.density and cell.element.properties.density > left.element.properties.density then
        swapCells(cell, down_left) -- Diagonal left movement

    elseif love.math.random(0, 100) > cell.element.properties.integrity * 100 and cell.isFalling and cell.element.properties.density > down_right.element.properties.density and cell.element.properties.density > right.element.properties.density then
        swapCells(cell, down_right) -- Diagonal right movement

    end

end

-- Liquid
function liquid(cell)
    
    if cell.element.properties.flammability and burnCheck() then
        if cell.element.properties.flammability > love.math.random() then
            setCell(cell, "fire")
        elseif cell.element.properties.ashes then
            setCell(cell, "ash")
        end

    elseif (cell.element.properties.solidify_time and cell.lifetime > cell.element.properties.solidify_time and cell.element.properties.solid) or (freezeCheck(cell) and cell.element.properties.solid) then
        solidify(cell)

    elseif burnCheck() then
        reactCells(cell, whichBurn(), cell.element.properties.gas)
    
    elseif corrodeCheck(cell, down) then
        reactCells(cell, down, cell.element.properties.gas)

    elseif down and cell.element.properties.density > down.element.properties.density and not down.checked then
        swapCells(cell, down) -- Falling
        
    else
        local goLeft = math.random(0, 1)

        if goLeft == 0 then
            if left and not left.checked then
                if corrodeCheck(cell, left) then
                    reactCells(cell, left, cell.element.properties.gas)

                elseif cell.element.properties.density > left.element.properties.density then
                    swapCells(cell, left) -- Left

                end
            end

        else
            if right and not right.checked then
                if corrodeCheck(cell, right) then
                    reactCells(cell, right, cell.element.properties.gas) 

                elseif cell.element.properties.density > right.element.properties.density then
                    swapCells(cell, right) -- Right

                end
            end
            
        end
    end

end

-- Gas
function _gas(cell)

    if cell.element.properties.flammability and burnCheck() then
        if cell.element.properties.flammability > love.math.random() then
            setCell(cell, "fire")
        elseif cell.element.properties.ashes then
            setCell(cell, "ash")
        end

    elseif cell.lifetime > cell.element.properties.condense_time then
        setCell(cell, cell.element.properties.liquid)

    elseif corrodeCheck(cell, up) and up and not up.checked then
        replaceCells(cell, up)

    elseif up and cell.element.properties.density < up.element.properties.density and up.element.properties.type ~= "solid" and not up.checked then
        swapCells(cell, up)

    else
        local goLeft = math.random(0, 1)
        if goLeft == 0 then
            if left and not left.checked then
                if corrodeCheck(cell, left) then
                    replaceCells(cell, left)

                elseif left.element.properties.type ~= "solid" and cell.element.properties.density < left.element.properties.density then
                    swapCells(cell, left)

                end
            end

        else
            if right and not right.checked then
                if corrodeCheck(cell, right) then
                    replaceCells(cell, right)

                elseif right.element.properties.type ~= "solid" and cell.element.properties.density < right.element.properties.density then
                    swapCells(cell, right)

                end
            end

        end

    end

end

-- Fire
function plasma_fire(cell)

    if cell.lifetime > cell.element.properties.condense_time and love.math.random() > 0.7 then 
        if love.math.random() > cell.element.properties.smoke_chance then
            setCell(cell, cell.element.properties.liquid)
        else
            setCell(cell, "empty")
        end

    elseif up and cell.element.properties.density < up.element.properties.density and up.element.properties.type ~= "solid" and not up.checked then
        swapCells(cell, up)

    else
        local goLeft = math.random(0, 1)
        if goLeft == 0 then
            if left.element.properties.type ~= "solid" and left and cell.element.properties.density < left.element.properties.density and not left.checked then
                swapCells(cell, left)
            end

        else
            if right.element.properties.type ~= "solid" and right and cell.element.properties.density < right.element.properties.density and not right.checked then
                swapCells(cell, right)
            end
            
        end
    end

end