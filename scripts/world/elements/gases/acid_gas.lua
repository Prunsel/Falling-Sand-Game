
-- Acid gas
acid_gas = {

    -- Element properties
    properties = {
        name  = "acid_gas",
        colour = {r = 0, g = 0.7, b = 0, a = 0.2},
        check = true,
        type = "gas",
        density = 0.4,
        corrosive_res = 1,
        corrosiveness = 0.401,
        condense_time = 1000,
        liquid = "acid",
    },
    
    
    update = function(cell)
        _gas(cell)
    end
    
}

return acid_gas