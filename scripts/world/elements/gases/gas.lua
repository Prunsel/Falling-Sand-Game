
-- Gas
gas = {

    -- Element properties
    properties = {
        name  = "gas",
        colour = {r = 0.1, g = 0.1, b = 0.2, a = 0.7},
        check = true,
        type = "gas",
        density = 0.32,
        corrosive_res = 1,
        condense_time = 1000,
        liquid = "empty",
        flammability = 0.4
    },
    
    
    update = function(cell) 
        _gas(cell)
    end
    
}

return gas