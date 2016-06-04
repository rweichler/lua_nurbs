VIEW = require 'lua.view'
local drawer = require 'func.drawer'
local move, draw = drawer()

local GRAPH = VIEW()
GRAPH.color = {255, 255, 255}

function GRAPH:coords()
    return function(t)
        t = t*20
        return math.sqrt(t)*20, t, 0
    end
end

local step = 0.001
function GRAPH:draw()
    local coords = self:coords()
    SET_COLOR(self.color[1]/255, self.color[2]/255, self.color[3]/255)
    move(coords(0))
    for t=step,1,step do
        draw(coords(t))
    end
end

return GRAPH
