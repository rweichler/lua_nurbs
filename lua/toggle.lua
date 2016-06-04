BUTTON = require 'lua.button'

local TOGGLE = BUTTON()

function TOGGLE:new()
    local self = BUTTON.new(self)
    self._on_color = {0, 255, 0}
    self._off_color = {255, 0, 0}
    self.on = false
    return self
end

function TOGGLE:set_on(on)
    self._on = on

    if on then
        self.color = self.on_color
    else
        self.color = self.off_color
    end
end

function TOGGLE:get_on()
    return self._on
end

function TOGGLE:set_on_color(on_color)
    self._on_color = on_color
    self.on = self.on
end

function TOGGLE:get_on_color()
    return self._on_color
end

function TOGGLE:set_off_color(off_color)
    self._off_color = off_color
    self.on = self.on
end

function TOGGLE:get_off_color()
    return self._off_color
end


function TOGGLE:pressed()
    BUTTON.pressed(self)
    self.on = not self.on
    self:toggled()
end

function TOGGLE:toggled()
end

return TOGGLE 
