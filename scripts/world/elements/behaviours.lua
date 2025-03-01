
-- Behaviours for cells


-- Solid
function solid(cell)
    if meltCheck(cell) then
        melt(cell)
    end
end