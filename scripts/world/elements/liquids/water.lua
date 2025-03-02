
-- Water
water = {

    -- Element properties
    properties = {
        name  = "water",
        colour = {r = 0.15, g = 0.58, b = 0.75, a = 0.4},
        check = true,
        type = "liquid",
        density = 1,
        corrosive_res = 0.2,
        dispersion_rate = 20,
        gas = "steam"
    },
    
    -- Water update
    update = function(cell)
        liquid(cell)
    end,
    
}

return water