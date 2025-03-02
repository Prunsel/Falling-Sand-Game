-- coal
coal = {
    properties = {
        name  = "coal", 
        colour = {r = 0.1, g = 0.1, b = 0.1, a = 1},
        noise = true,
        check = true,
        type = "solid",
        density = 2,
        corrosive_res = 0.3,
        integrity = 0.9,
        flammability = 0.15
    },

    update = function(cell)
        powder(cell)
    end
}

return coal