
-- Steam
steam = {
    -- Element properties
    properties = {
        name  = "steam",
        colour = {r = 0.15, g = 0.58, b = 0.75, a = 0.1},
        check = true,
        type = "gas",
        density = 0.41,
        corrosive_res = 0.4,
        condense_time = 1000,
        liquid = "water",
    },
    
    update = function(cell)
        _gas(cell)
    end
    
}

return steam