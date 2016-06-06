GRAPH = require 'lua.graph'

local NURBS = GRAPH()

function NURBS:new()
    local self = GRAPH.new(self)

    self.spline = ffi.new("tsBSpline[1]")

    return self
end

local DIM = 4
function NURBS:init(dont_free)
    local points = self.points
    local knots = self.knots
    assert(self.degree)
    assert(points)
    assert(knots)
    assert(#points + self.degree + 1 == #knots)
    local TS_CLAMPED = 1
    if not dont_free then
        ffi.C.ts_bspline_free(self.spline)
    end
    local err = ffi.C.ts_bspline_new(self.degree, DIM, #points, TS_CLAMPED, self.spline)
    if err < 0 then
        error(ffi.C.ts_enum_str(err))
    end

    self:update_points()
    self:update_knots()
end

function NURBS:update_points()
    local points = self.points
    local spline = self.spline[0]
    for i,v in ipairs(points) do
        local idx = (i - 1)*DIM
        for i=1,DIM do
            spline.ctrlp[idx + i - 1] = v[i]
        end
    end
end
function NURBS:update_knots()
    local knots = self.knots
    local spline = self.spline[0]
    for i, v in ipairs(knots) do
        spline.knots[i - 1] = v
    end
end

function NURBS:coords()
    if not self.points and not self.knots and not self.spline then return end
    local first = self.knots[self.degree + 1]
    local last = self.knots[#self.knots - self.degree]
    local span = last - first
    local EVALUATE_SPLINE = EVALUATE_SPLINE
    local spline = self.spline
    return function(t)
        local u = t*span + first
        local pt = EVALUATE_SPLINE(spline, u)
        return pt[0]/pt[3], pt[1]/pt[3], pt[2]/pt[3]
    end
end


return NURBS
