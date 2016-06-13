VIEW = require 'lua.view'
POINT_VIEW = require 'lua.view.point'
BSPLINE = require 'lua.bspline'

local GRID = VIEW()

local SCALE = 1
local BRIGHT_COLOR = {0, 255, 0}
local DIM_COLOR = {100, 100, 100}

GRID._resolution = 10

ROW_ORDER = 2
COLUMN_ORDER = 2

ROW_KNOTS = {}
COLUMN_KNOTS = {}

function print_knots(tbl)
    local str = "{"
    for k,v in ipairs(tbl) do
        str = str..v
        if k ~= #tbl then
            str = str..", "
        end
    end
    str = str.."}"
    return str
end

local function gen_knots(count)
    local knots = {}
    for i=1,count do
        knots[i] = (i-1)/(count + 1)
    end
    return knots
end

function GRID:new(m, n)
    assert(m > 0 and n > 0)
    local self = VIEW.new(self)


    self.color = {100, 255, 255}
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

    self:redo_knots()

    self:eval()
    return self
end

function GRID:redo_knots()
    ROW_KNOTS = gen_knots(#self.points + ROW_ORDER)
    COLUMN_KNOTS = gen_knots(#self.points[1] + COLUMN_ORDER)
end


function GRID:set_row_order(order)
    ROW_ORDER = order
    self:redo_knots()
end

function GRID:set_column_order(order)
    COLUMN_ORDER = order
    self:redo_knots()
end

function GRID:get_row_order()
    return ROW_ORDER
end

function GRID:get_column_order()
    return COLUMN_ORDER
end

function GRID:add_column(at_end)
    local new_column = {}
    local last_column
    local delta
    if at_end then
        last_column = self.points[#self.points]
        delta = 1
    else
        last_column = self.points[1]
        delta = -1
    end

    for i, v in ipairs(last_column) do
        local pt = POINT_VIEW()
        pt.color = DIM_COLOR
        pt.x = v.x + delta
        pt.y = v.y
        pt.z = v.z
        pt.weight = v.weight
        table.insert(new_column, pt)
        self:add_subview(pt)
    end
    if at_end then
        table.insert(self.points, new_column)
    else
        table.insert(self.points, 1, new_column)
    end
    self:redo_knots()
    self:eval()
end

function GRID:add_row(at_end)
    local delta = at_end and 1 or -1
    for i, tbl in ipairs(self.points) do
        local v
        if at_end then
            v = tbl[#tbl]
        else
            v = tbl[1]
        end
        local pt = POINT_VIEW()
        pt.color = DIM_COLOR
        pt.x = v.x
        pt.y = v.y
        pt.z = v.z + delta
        pt.weight = v.weight
        if at_end then
            table.insert(tbl, pt)
        else
            table.insert(tbl, 1, pt)
        end
        self:add_subview(pt)
    end
    self:redo_knots()
    self:eval()
end

function GRID:delete_column(at_end)
    local column
    if at_end then
        column = self.points[#self.points]
        table.remove(self.points, #self.points)
    else
        column = self.points[1]
        table.remove(self.points, 1)
    end
    for i, v in ipairs(column) do
        v:remove_from_superview()
    end
    self:redo_knots()
    self:eval()
end

function GRID:delete_row(at_end)
    for i, tbl in ipairs(self.points) do
        local idx = at_end and #tbl or 1
        local pt = tbl[idx]
        pt:remove_from_superview()
        table.remove(tbl, idx)
    end
    self:redo_knots()
    self:eval()
end

local function generate_knots(spline)
    spline.knots = gen_knots(#spline.points + spline.degree + 1)
end
local DEGRE = 2
function GRID:eval_internal(rows, this_order, other_order, this_knots, other_knots)
    local round_1 = {}
    for i,v in ipairs(rows) do
        local spline = BSPLINE()
        spline.degree = this_order - 1
        spline.points = v
        spline.knots = this_knots
        spline:init()
        table.insert(round_1, spline)
    end
    for t=0,1, 1/self.resolution do
        local spline = BSPLINE()
        spline.color = self.color
        spline.points = {}
        spline.degree = other_order - 1
        for i, v in ipairs(round_1) do
            local pt = {v:coords()(t)}
            table.insert(pt, 1)
            table.insert(spline.points, pt)
        end
        spline.knots = other_knots
        spline:init()
        table.insert(self.splines, spline)
        self:add_subview(spline)
    end
end

function GRID:set_resolution(r)
    self._resolution = r
    self:eval()
end

function GRID:get_resolution()
    return self._resolution
end

function GRID:eval()
    if self.splines then
        for i, v in ipairs(self.splines) do
            v:remove_from_superview()
        end
    end
    self.splines = {}

    --horizontal
    self:eval_internal(self.points, COLUMN_ORDER, ROW_ORDER, COLUMN_KNOTS, ROW_KNOTS)

    --vertical
    local points = {}
    for i=1, #self.points[1] do
        local pts = {}
        table.insert(points, pts)
        for _, v in ipairs(self.points) do
            table.insert(pts, v[i])
        end
    end
    self:eval_internal(points, ROW_ORDER, COLUMN_ORDER, ROW_KNOTS, COLUMN_KNOTS)
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
        if self.selected_point then
            self.selected_point.color = BRIGHT_COLOR
        end
    else
        DIM_COLOR[1] = 100
        DIM_COLOR[2] = 100
        DIM_COLOR[3] = 100
        if self.selected_point then
            self.selected_point.color = DIM_COLOR
        end
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

local pt_keyfuncs = require 'lua.func.point_keys'

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
        self:eval()
        return true
    end
    local f = keyfuncs[key]
    if f then
        f(self)
        return true
    end
end

return GRID
