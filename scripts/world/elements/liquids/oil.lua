
-- Oil
oil = {

    -- Element properties
    properties = {
        name  = "oil",
        colour = {r = 0.01, g = 0.01, b = 0.01, a = 0.9},
        check = true,
        type = "liquid",
        density = 1.2,
        corrosive_res = 0.5,
        flammability = 0.3,
    },
    
    update = function(cell)
        liquid(cell)
    end,
    
}

return oil