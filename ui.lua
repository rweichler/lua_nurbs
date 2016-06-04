local ffi = require 'ffi'
local bit = require 'bit'
VIEW = require 'lua.view'
TOGGLE = require 'lua.toggle'
POINT_VIEW = require 'lua.view.point'
GRID = require 'lua.view.point_grid'

ffi.cdef[[
void glColor3f(float, float, float);
void l_fill_rect(int x, int y, int width, int height, char r, char g, char b);
void l_draw_line(float x1, float y1, float z1, float x2, float y2, float z2);
void glutPostRedisplay();
float *l_camera();
float *l_rotation();
int glutGetModifiers();
]]

DELTA = 1
ROTATION_DELTA = math.pi/24

CAMERA = ffi.C.l_camera()
ROTATION = ffi.C.l_rotation()

CAMERA[0] = DELTA*5
CAMERA[1] = DELTA*5
CAMERA[2] = -DELTA*20

SET_COLOR = ffi.C.glColor3f
FILL_RECT = ffi.C.l_fill_rect
DRAW_LINE = ffi.C.l_draw_line
REDISPLAY = ffi.C.glutPostRedisplay

local window = VIEW()
window.width = SCREEN_WIDTH
window.height = SCREEN_HEIGHT

local grid = GRID(2, 2)
window:add_subview(grid)

local toggle = TOGGLE:new()
toggle.x = 20
toggle.y = 20
toggle.width = 60
toggle.height = 60
toggle.toggled = function(self)
    if self.on then
        grid.active = true
    else
        grid.active = false
    end
    REDISPLAY()
end
window:add_subview(toggle)

local drawer = require 'func.drawer'



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

local camera_keyfuncs = require 'func.camera_keys'
local point_keyfuncs = require 'func.point_keys'
function keypress(key)
    local func
    if toggle.on then
        func = point_keyfuncs[key]
    else
        func = camera_keyfuncs[key]
    end
    if func then
        func(grid.selected_point)
        print('yee')
        REDISPLAY()
    end
end
