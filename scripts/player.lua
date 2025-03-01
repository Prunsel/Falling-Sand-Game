    -- Player
player = {
    properties = {
        name  = "player", 
        colour = {r = 1, g = 1, b = 1},
        check = true,
        type = "entity",
        density = 7,
        corrosive_res = 0
    },

    update = function(cell)

        if up.element.properties.type ~= "solid" and love.keyboard.isDown("w") then -- Flying
            if love.keyboard.isDown("d") and up_right.element.properties.type ~= "solid" then
                swapCells(cell, up_right)
            elseif love.keyboard.isDown("a") and up_left.element.properties.type ~= "solid" then
                swapCells(cell, up_left)
            else
                swapCells(cell, up)
            end 
        
        elseif down.element.properties.type ~= "solid" then -- Falling
            if love.keyboard.isDown("d") and down_right.element.properties.type ~= "solid" then
                swapCells(cell, down_right)
            elseif love.keyboard.isDown("a") and down_left.element.properties.type ~= "solid" then
                swapCells(cell, down_left)
            else
                swapCells(cell, down)
            end 

        else -- Moving left and right
            if love.keyboard.isDown("d") then 
                if right.element.properties.type ~= "solid" then
                    swapCells(cell, right)
                elseif up_right.element.properties.type ~= "solid" and up.element.properties.type ~= "solid" then
                    swapCells(cell, up_right)
                end

            end
            if love.keyboard.isDown("a") then
                if left.element.properties.type ~= "solid" then
                    swapCells(cell, left)
                elseif up_left.element.properties.type ~= "solid" and up.element.properties.type ~= "solid" then
                    swapCells(cell, up_left)
                end
                
            end

        end

    end
}

return player