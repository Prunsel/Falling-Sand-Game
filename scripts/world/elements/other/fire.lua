
-- Fire
fire = {

    -- Element properties
    properties = {
        name  = "fire",
        colour = {r = 1, g = 0, b = 0, a = 1},
        noise_chaos = true,
        check = true,
        type = "gas",
        density = 0.3,
        corrosive_res = 1,
        burn = true,
        condense_time = 10,
        liquid = "smoke",
        smoke_chance = 0.7,
    },
    
    
    update = function(cell)
        plasma_fire(cell)
    end,
    
}

return fire