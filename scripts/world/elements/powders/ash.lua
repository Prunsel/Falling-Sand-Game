-- Sand
ash = {
    properties = {
        name  = "ash", 
        colour = {r = 0.6, g = 0.6, b = 0.6, a = 1},
        noise = true,
        check = true,
        type = "solid",
        density = 2,
        corrosive_res = 0.3,
        integrity = 0.2,
        flammability = 0.1,
        ashes = true
    },

    update = function(cell)
        powder(cell)
    end
}

return ash