VIEW = require 'lua.view'

local POINT = VIEW()

function POINT:new()
    local self = VIEW.new(self)
    self.color = {255, 255, 255}
    self.z = 0
    self.size = 0.25
    return self
end

function POINT:get_x()
    return self._x
end
function POINT:set_x(x)
    self._x = x
    self[1] = x*self.weight
end
function POINT:get_y()
    return self._y
end
function POINT:set_y(y)
    self._y = y
    self[2] = y*self.weight
end
function POINT:get_z()
    return self._z
end
function POINT:set_z(z)
    self._z = z
    self[3] = z*self.weight
end
function POINT:get_weight()
    if not self[4] then
        self[4] = 1
    end
    return self[4]
end
function POINT:set_weight(weight)
    local old = self.weight
    for i=1,3 do
        self[i] = self[i]*weight/old
    end
    self[4] = weight
end

local drawer = require 'lua.func.drawer'

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
