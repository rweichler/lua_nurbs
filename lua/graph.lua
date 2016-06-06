VIEW = require 'lua.view'
local drawer = require 'func.drawer'
local move, draw = drawer()

local GRAPH = VIEW()
GRAPH.color = {255, 255, 255}

function GRAPH:coords()
    local s = 10
    return function(t)
        t = t*s
        return math.sqrt(t)/s*10, t, 0
    end
end

local step = 0.001
function GRAPH:draw()
    local coords = self:coords()
    if not coords then return end
    SET_COLOR(self.color[1]/255, self.color[2]/255, self.color[3]/255)

    local moved = false
    for t=0,1,step do
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
