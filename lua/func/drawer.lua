
return function(center_x, center_y, center_z)
    center_x = center_x or 0
    center_y = center_y or 0
    center_z = center_z or 0
    local x = 0
    local y = 0
    local z = 0
    local move = function(xx, yy, zz)
        x = xx
        y = yy
        z = zz
    end
    local draw = function(xx, yy, zz)
        DRAW_LINE(center_x + x, center_y + y, center_z + z, center_x + xx, center_y + yy, center_z + zz)
        move(xx, yy, zz)
    end
    return move, draw
end
