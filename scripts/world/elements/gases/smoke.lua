
-- Smoke
smoke = {

    -- Element properties
    properties = {
        name  = "smoke",
        colour = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
        check = true,
        type = "gas",
        density = 0.31,
        corrosive_res = 1,
        condense_time = 1000,
        liquid = "empty"
    },
    
    
    update = function(cell) 
        _gas(cell)
    end
    
}

return smoke