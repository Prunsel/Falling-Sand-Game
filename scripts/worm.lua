
-- Worm script
worm = {}

-- Require main


-- Worm init
function worm:init()

    -- Require main
    require "main"

    -- Worm table
    worm_table = {}

    -- Worm's speed
    wormspd = 10

    -- Friction
    friction = 100

    -- Segments
    wormsegm = 20

    -- Head and body sprites
    head = love.graphics.newImage("assets/sprites/worm/head.png")
    body = love.graphics.newImage("assets/sprites/worm/body.png")

end

-- Worm update
function worm:update()
    -- Moves worm towards mouse
    for i,segm in ipairs(worm_table) do
        if i==1 then
            segm.xv = segm.xv + (love.mouse.getX()-segm.x)
            segm.yv = segm.yv + (love.mouse.getY()-segm.y)
            segm.x = segm.x + segm.xv
            segm.y = segm.y + segm.yv
            segm.xv = segm.xv / friction
            segm.yv = segm.yv / friction
        elseif i ~= 1 then
            local mysegm = worm_table[i]
            local prevsegm = worm_table[i - 1]
            local r = prevsegm.r
            local x1 = mysegm.x
            local y1 = mysegm.y
            local x2 = prevsegm.x
            local y2 = prevsegm.y
            local d = distance(mysegm.x, mysegm.y, x2, y2)
            local dx = x2-x1
            local dy = y2-y1
            local spd = 1.7
   
            for i=1,d-r do
                mysegm.x = mysegm.x + (dx/d)
                mysegm.y = mysegm.y + (dy/d)
            end
        end
        
    end
end

-- Worm draw
function worm:draw()
    for i,segm in ipairs(worm_table) do

        
        if i == 1 then -- Head
            -- Direction to mouse
            local direction = math.atan2(mouse.y - segm.y, mouse.x - segm.x)
            love.graphics.draw(head, segm.x, segm.y, direction, worm_table[i].r / 16, worm_table[i].r / 16, worm_table[i].r / 2, worm_table[i].r / 2) 

        elseif i ~= 1 then -- Body
            -- Direction to next segment
            local direction = math.atan2(worm_table[i - 1].y - segm.y, worm_table[i - 1].x - segm.x)
            love.graphics.draw(body, segm.x, segm.y, direction, worm_table[i].r / 16, worm_table[i].r / 16, worm_table[i].r / 2, worm_table[i].r / 2)

        end

    end
end

-- Spawn worm
function worm:spawn(x, y)
    
    -- Worm generation
    for i=1,wormsegm do
        local newsegm={}

        if i==1 then
            newsegm.xv = 0
            newsegm.yv = 0
        end

        -- Start position
        newsegm.x = 64
        newsegm.y = 64

        -- Thickness
        newsegm.r = 20

        -- Colour
        newsegm.col = 8
        newsegm.id = i

        table.insert(worm_table, newsegm)
    end

end

return worm