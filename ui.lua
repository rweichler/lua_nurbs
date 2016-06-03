local ffi = require 'ffi'

ffi.cdef[[
void glColor3f(float, float, float);
void l_fill_rect(int x, int y, int width, int height, char r, char g, char b);
void l_draw_line(float x1, float y1, float z1, float x2, float y2, float z2);
void glutPostRedisplay();
]]

local SET_COLOR = ffi.C.glColor3f
local FILL_RECT = ffi.C.l_fill_rect
local DRAW_LINE = ffi.C.l_draw_line
local REDISPLAY = ffi.C.glutPostRedisplay

local s = 10

local function drawer(x, y, z)
    x = x or 0
    y = y or 0
    z = z or 0
    local move = function(xx, yy, zz)
        x = xx
        y = yy
        z = zz
    end
    local draw = function(xx, yy, zz)
        DRAW_LINE(x, y, z, xx, yy, zz)
        move(xx, yy, zz)
    end
    return move, draw
end


function display()
    local MOVE, DRAW = drawer()

    MOVE(0, 0, 0)
    SET_COLOR(1.0, 0.0, 0.0)
    DRAW(0, 0, s)
    DRAW(s, 0, s)
    DRAW(s, 0, 0)
    DRAW(0, 0, 0)

    MOVE(0, s, 0)
    SET_COLOR(0, 1, 0)
    DRAW(0, s, s)
    DRAW(s, s, s)
    DRAW(s, s, 0)
    DRAW(0, s, 0) 

    SET_COLOR(0, 0, 1)
    DRAW(0, 0, 0)
    MOVE(0, 0, s)
    DRAW(0, s, s)
    MOVE(s, 0, s)
    DRAW(s, s, s)
    MOVE(s, 0, 0)
    DRAW(s, s, 0)

    FILL_RECT(20, 20, 60, 60, 255, 255, 0)
end

function click(button, state, x, y)
end

function drag(x, y)
end
