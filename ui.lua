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


function display()
    FILL_RECT(20, 20, 60, 60, 255, 255, 0)
end

function click(button, state, x, y)
end

function drag(x, y)
end
