
-- Empty
empty = {
    properties = {
        name  = "empty", 
        colour = {r = 0, g = 0, b = 0}, 
        physics = "gas", 
        density = 0.3, 
        corrosive_res = 1
    },
    
    -- Wall update
    update = function(cell)
    
    end
}

return empty