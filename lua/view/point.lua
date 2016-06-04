VIEW = require 'lua.view'

local POINT = VIEW()

function POINT:new()
    local self = VIEW.new(self)
    self.color = {255, 255, 255}
    self.z = 0
    self.size = 0.25
    return self
end

local drawer = require 'func.drawer'

function POINT:draw()
    local move, draw = drawer(self.x, self.y, self.z)
    local s = self.size/2
    SET_COLOR(self.color[1]/255, self.color[2]/255, self.color[3]/255)
    move(-s, -s, -s)
    draw(-s, -s, s)
    draw(s, -s, s)
    draw(s, -s, -s)
    draw(-s, -s, -s)

    move(-s, s, -s)
    draw(-s, s, s)
    draw(s, s, s)
    draw(s, s, -s)
    draw(-s, s, -s)

    draw(-s, -s, -s)
    move(s, s, -s)
    draw(s, -s, -s)
    move(-s, s, s)
    draw(-s, -s, s)
    move(s, s, s)
    draw(s, -s, s)
end

return POINT
