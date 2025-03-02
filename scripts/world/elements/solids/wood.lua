
-- Wood
wood = {
    properties = {
        name  = "wood", 
        colour = {r = 88 / 255, g = 58 / 255, b = 19 / 255, a = 1},
        noise = true,
        check = true,
        type = "solid",
        density = 10,
        corrosive_res = 0.1,
        flammability = 0.2,
        ashes = true
    },

    update = function(cell)
        solid(cell)
    end
}

return wood