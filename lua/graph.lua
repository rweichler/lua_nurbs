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

GRAPH_RESOLUTION = 250

local max_dist = 26
function GRAPH:draw()
    local coords = self:coords()
    if not coords then return end

    local r, g, b = self.color[1]/255, self.color[2]/255, self.color[3]/255

    SET_COLOR(r, g, b)

    local moved = false
    for t=0,1,1/GRAPH_RESOLUTION do
        local x, y, z = coords(t)
        if x and y and z then
            if not moved then
                move(x, y, z)
                moved = true
            else
                draw(x, y, z)
            end
        end
    end
end

return GRAPH
