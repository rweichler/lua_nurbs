VIEW = require 'lua.view'
POINT_VIEW = require 'lua.view.point'
BSPLINE = require 'lua.bspline'

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
    self.bspline = BSPLINE()
    self.bspline.degree = 2
    self.bspline.points = self.points[1]
    self.bspline.knots = {}
    local count = #self.points[1] + self.bspline.degree + 1
    for i=1,count do
        self.bspline.knots[i] = (i-1)/(count + 1)
    end
    self.bspline:init()
    self:add_subview(self.bspline)
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

local pt_keyfuncs = require 'func.point_keys'

local keyfuncs = {}
keyfuncs.up = function(self)
    local x = self.selected_x
    local y = self.selected_y
    y = y + 1
    if y > #self.points[x] then
        y = 1
    end
    self:set_selected(x, y)
end
keyfuncs.down = function(self)
    local x = self.selected_x
    local y = self.selected_y
    y = y - 1
    if y < 1 then
        y = #self.points[x] 
    end
    self:set_selected(x, y)
end
keyfuncs.left = function(self)
    local x = self.selected_x
    local y = self.selected_y
    x = x - 1
    if x < 1 then
        x = #self.points 
    end
    self:set_selected(x, y)
end
keyfuncs.right = function(self)
    local x = self.selected_x
    local y = self.selected_y
    x = x + 1
    if x > #self.points then
        x = 1
    end
    self:set_selected(x, y)
end

function GRID:keypress(key)
    local f = pt_keyfuncs[key]
    if f then
        f(self.selected_point)
        self.bspline:init()
        return true
    end
    local f = keyfuncs[key]
    if f then
        f(self)
        return true
    end
end

return GRID
