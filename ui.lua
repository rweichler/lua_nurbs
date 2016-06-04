local ffi = require 'ffi'
local bit = require 'bit'
VIEW = require 'lua.view'
TOGGLE = require 'lua.toggle'

ffi.cdef[[
void glColor3f(float, float, float);
void l_fill_rect(int x, int y, int width, int height, char r, char g, char b);
void l_draw_line(float x1, float y1, float z1, float x2, float y2, float z2);
void glutPostRedisplay();
float *l_camera();
float *l_rotation();
int glutGetModifiers();
]]

CAMERA = ffi.C.l_camera()
ROTATION = ffi.C.l_rotation()

SET_COLOR = ffi.C.glColor3f
FILL_RECT = ffi.C.l_fill_rect
DRAW_LINE = ffi.C.l_draw_line
REDISPLAY = ffi.C.glutPostRedisplay

local window = VIEW()
window.width = SCREEN_WIDTH
window.height = SCREEN_HEIGHT

local yellow = TOGGLE:new()
yellow.x = 20
yellow.y = 20
yellow.width = 60
yellow.height = 60

window:add_subview(yellow)

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
    local move, draw = drawer()

    local s = 10

    move(0, 0, 0)
    SET_COLOR(1.0, 0.0, 0.0)
    draw(0, 0, s)
    draw(s, 0, s)
    draw(s, 0, 0)
    draw(0, 0, 0)

    move(0, s, 0)
    SET_COLOR(0, 1, 0)
    draw(0, s, s)
    draw(s, s, s)
    draw(s, s, 0)
    draw(0, s, 0) 

    SET_COLOR(0, 0, 1)
    draw(0, 0, 0)
    move(0, 0, s)
    draw(0, s, s)
    move(s, 0, s)
    draw(s, s, s)
    move(s, 0, 0)
    draw(s, s, 0)

    window:render()
end

function click(button, state, x, y)
    local DOWN = 0
    local UP = 1
    local MOUSE1 = 0

    if not button == MOUSE1 then return end
    local shift_pressed = bit.band(ffi.C.glutGetModifiers(), 1) == 1

    if window:mouse(state == DOWN, x, y, shift_pressed) then
        REDISPLAY()
    end
end

function drag(x, y)
    if window:drag(x, y) then
        REDISPLAY()
    end
end

local keyfuncs = {}
local DELTA = 1
local sinf = math.sin
local cosf = math.cos
keyfuncs.w = function()
    local a = ROTATION[0]
    CAMERA[2] = CAMERA[2] +  cosf(a)*DELTA
    CAMERA[0] = CAMERA[0] + sinf(a)*DELTA
end
keyfuncs.a = function()
    local a = ROTATION[0]
    CAMERA[0] = CAMERA[0] - cosf(a)*DELTA
    CAMERA[2] = CAMERA[2] + sinf(a)*DELTA
end
keyfuncs.s = function()
    local a = ROTATION[0]
    CAMERA[2] = CAMERA[2] - cosf(a)*DELTA
    CAMERA[0] = CAMERA[0] - sinf(a)*DELTA
end
keyfuncs.d = function()
    local a = ROTATION[0]
    CAMERA[0] = CAMERA[0] + cosf(a)*DELTA
    CAMERA[2] = CAMERA[2] - sinf(a)*DELTA
end
keyfuncs.r = function()
    local a = ROTATION[0]
    CAMERA[1] = CAMERA[1] + DELTA
end
keyfuncs.f = function()
    local a = ROTATION[0]
    CAMERA[1] = CAMERA[1] - DELTA
end
keyfuncs[' '] = function()
    ROTATION[0] = 0
    ROTATION[1] = 0
end

function keypress(key)
    local func = keyfuncs[key]
    if func then
        func()
        REDISPLAY()
    end
end
