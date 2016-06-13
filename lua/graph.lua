VIEW = require 'lua.view'
local drawer = require 'lua.func.drawer'
local move, draw = drawer()

local GRAPH = VIEW()
GRAPH.color = {255, 255, 255}

function GRAPH:coords()
    local s = 10
    return function(t)
        t = t*s
        return math.sqrt(t)/s*10, t, math.sin(t)
    end
end

local light_x, light_y, light_z = 20, 20, 20
local sqrt = math.sqrt
local pow = math.pow
local function dist(x, y, z)
    return sqrt(pow(light_x - x, 2), pow(light_y - y, 2), pow(light_z - z, 2))
end


GRAPH_RESOLUTION = 0.004

local max_dist = 26
function GRAPH:draw()
    local coords = self:coords()
    if not coords then return end

    local r, g, b = self.color[1]/255, self.color[2]/255, self.color[3]/255

    SET_COLOR(r, g, b)

    local step = GRAPH_RESOLUTION

    local SET_COLOR = SET_COLOR
    local moved = false
    local function forloop(t)
        local x, y, z = coords(t)
        if x and y and z then
            if not moved then
                move(x, y, z)
                moved = true
            else
                local distance = dist(x, y, z)
                distance = (max_dist - distance)/max_dist
                if distance < 0 then distance = 0 end
                SET_COLOR(r*distance, g*distance, b*distance)
                draw(x, y, z)
            end
        end
    end
    for t=0,1,step do
        forloop(t)
    end

    forloop(1)

end

return GRAPH
