
-- Acid
acid = {

    -- Element properties
    properties = {
        name  = "acid",
        colour = {r = 0, g = 0.8, b = 0, a = 0.4},
        check = true,
        type = "liquid",
        density = 0.9,
        corrosive_res = 1,
        corrosiveness = 0.5,
        gas = acid_gas
    },
    
    
    update = function(cell)

        

    end,
    
}

return acid