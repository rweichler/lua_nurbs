--functions for manipulating the camera position / angle

local keyfuncs = {}
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
local function fix_rotation()
    if ROTATION[1] > math.pi/2 then
        ROTATION[1] = math.pi/2
    elseif ROTATION[1] < -math.pi/2 then
        ROTATION[1] = -math.pi/2
    end
    while ROTATION[0] > 2*math.pi do
        ROTATION[0] = ROTATION[0] - 2*math.pi
    end
    while ROTATION[0] < -2*math.pi do
        ROTATION[0] = ROTATION[0] + 2*math.pi
    end
end
keyfuncs.up = function()
    ROTATION[1] = ROTATION[1] + ROTATION_DELTA
    fix_rotation()
end
keyfuncs.down = function()
    ROTATION[1] = ROTATION[1] - ROTATION_DELTA
    fix_rotation()
end
keyfuncs.left = function()
    ROTATION[0] = ROTATION[0] - ROTATION_DELTA
    fix_rotation()
end
keyfuncs.right = function()
    ROTATION[0] = ROTATION[0] + ROTATION_DELTA
    fix_rotation()
end
return keyfuncs
