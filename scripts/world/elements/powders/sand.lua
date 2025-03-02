-- Sand
sand = {
    properties = {
        name  = "sand", 
        colour = {r = 1, g = 0.9, b = 0.5, a = 1},
        noise = true,
        check = true,
        type = "solid",
        density = 2,
        corrosive_res = 0.3,
        integrity = 0.4
    },

    update = function(cell)
        powder(cell)
    end
}

return sand