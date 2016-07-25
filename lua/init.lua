ffi = require 'ffi'
local bit = require 'bit'

DELTA = 1
ROTATION_DELTA = math.pi/24

VIEW = require 'lua.view'
TOGGLE = require 'lua.toggle'
POINT_VIEW = require 'lua.view.point'
GRID = require 'lua.view.point_grid'
GRAPH = require 'lua.graph'
CONSOLE = require 'lua.console'

ffi.cdef[[
void glColor3f(float, float, float);
void l_ffi_fill_rect(int x, int y, int width, int height, char r, char g, char b);
void l_ffi_draw_line(float x1, float y1, float z1, float x2, float y2, float z2);
void glutPostRedisplay();
void l_ffi_draw_text(const char *str, int x, int y);
float *l_ffi_camera_position();
float *l_ffi_camera_rotation();
int glutGetModifiers();
]]

CAMERA = ffi.C.l_ffi_camera_position()
ROTATION = ffi.C.l_ffi_camera_rotation()

CAMERA[0] = DELTA*5
CAMERA[1] = DELTA*5
CAMERA[2] = -DELTA*20

SET_COLOR = ffi.C.glColor3f
FILL_RECT = ffi.C.l_ffi_fill_rect
DRAW_LINE = ffi.C.l_ffi_draw_line
REDISPLAY = ffi.C.glutPostRedisplay
DRAW_TEXT = ffi.C.l_ffi_draw_text

local window = VIEW()
window.width = SCREEN_WIDTH
window.height = SCREEN_HEIGHT

local console = CONSOLE()
window:add_subview(console)

grid = GRID(6, 6)
window:add_subview(grid)

function display()
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

local camera_keyfuncs = require 'lua.func.camera_keys'
function keypress(key, down)
    if not down then return end

    if console:keypress(key) then
        REDISPLAY()
        return
    end
    if key == 'q' then
        grid.active = not grid.active
        REDISPLAY()
        return
    end
    if grid.active then
        if grid:keypress(key) then
            REDISPLAY()
        end
    else 
        local func = camera_keyfuncs[key]
        if func then
            func(grid.selected_point)
            REDISPLAY()
        end
    end
end


exit = os.exit
