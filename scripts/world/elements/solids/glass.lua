
-- Glass
glass = {
    properties = {
        name  = "glass", 
        colour = {r = 0.9, g = 0.9, b = 1, a = 0.3},
        noise = false,
        check = true,
        type = "solid",
        density = 10,
        corrosive_res = 1,
    },

    update = function(cell)
        solid(cell)
    end
}

return glass