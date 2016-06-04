VIEW = require 'lua.view'
POINT_VIEW = require 'lua.view.point'

local GRID = VIEW()

local SCALE = 1
local BRIGHT_COLOR = {0, 255, 0}
local DIM_COLOR = {100, 100, 100}

function GRID:new(m, n)
    assert(m > 0 and n > 0)

    local self = VIEW.new(self)
    self.points = {}
    for i=1,m do
        self.points[i] = {}
        for j=1,n do
            local pt = POINT_VIEW()
            pt.color = DIM_COLOR
            pt.x = SCALE*i
            pt.z = SCALE*j
            self.points[i][j] = pt
            self:add_subview(pt)
        end
    end
    self:set_selected(1, 1)
    return self
end

function GRID:get_active()
    return self._active
end

function GRID:set_active(active)
    self._active = active
    if active then
        DIM_COLOR[1] = 255
        DIM_COLOR[2] = 255
        DIM_COLOR[3] = 255
        self.selected_point.color = BRIGHT_COLOR
    else
        DIM_COLOR[1] = 100
        DIM_COLOR[2] = 100
        DIM_COLOR[3] = 100
        self.selected_point.color = DIM_COLOR
    end
end

function GRID:get_selected_point()
    local x = self.selected_x
    local y = self.selected_y
    if x and y then
        return self.points[x][y]
    end
end

function GRID:set_selected(x, y)
    if self.selected_point then
        self.selected_point.color = DIM_COLOR
    end
    self.selected_x = x
    self.selected_y = y
    if self.active then
        self.selected_point.color = BRIGHT_COLOR
    end
end

return GRID
