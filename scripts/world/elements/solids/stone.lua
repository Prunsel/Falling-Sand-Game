
-- Stone
stone = {
    properties = {
        name  = "stone", 
        colour = {r = 0.3, g = 0.3, b = 0.3},
        noise = true,
        check = true,
        type = "solid",
        density = 10,
        corrosive_res = 0.3,
    },

    update = function(cell)
        solid(cell)
    end
}

return stone