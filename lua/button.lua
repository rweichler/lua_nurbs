VIEW = require 'lua.view'

local BUTTON = VIEW()

function BUTTON:new()
    local self = VIEW.new(self)
    return self
end

function BUTTON:set_width(width)
    self._width = width
end

function BUTTON:get_width()
    return self._width
end

function BUTTON:set_height(height)
    self._height = height
end

function BUTTON:get_height()
    return self._height
end

function BUTTON:set_color(color)
    if not self.background_color then
        self.background_color = color
    end
    self._color = color
    self.pressed_color = {color[1]/2, color[2]/2, color[3]/2}
end
function BUTTON:get_color()
    return self._color
end

function BUTTON:mouse(down, x, y, shift_pressed)
    x = x - self.x
    y = y - self.y
    if not down and self.leftmdown and self:contains(x, y) then
        self:pressed(shift_pressed)
    end
    local should_refresh = VIEW.mouse(self, down, x + self.x, y + self.y)
    if self.leftmdown and self.pressed_color then
        self.background_color = self.pressed_color
        return true
    elseif not down then
        self.background_color = self.color
        return true
    end
    return should_refresh
end

function BUTTON:drag(x, y)
    VIEW.hover(self, x, y)
    x = x - self.x
    y = y - self.y
    if not self.leftmdown then return end
    if self:contains(x, y) then
        if self.background_color ~= self.pressed_color then
            self.background_color = self.pressed_color
            return true
        end
    else
        if self.background_color ~= self.color then
            self.background_color = self.color
            return true
        end
    end

end

function BUTTON:pressed()
    print('pressed!')
end

return BUTTON
