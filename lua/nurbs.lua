GRAPH = require 'lua.graph'

local NURBS = GRAPH()

function NURBS:new()
    local self = GRAPH.new(self)

    self.spline = ffi.new("tsBSpline[1]")

    return self
end




local DIM = 4
function NURBS:init(points, knots)
    points = points or self.points
    knots = knots or self.knots
    assert(self.degree)
    assert(points)
    assert(knots)
    assert(#points + self.degree + 1 == #knots)
    local TS_CLAMPED = 1
    ffi.C.ts_bspline_free(self.spline)
    ffi.C.ts_bspline_new(self.degree, DIM, #points, TS_CLAMPED, self.spline)
    local spline = self.spline[0]
    for i, v in ipairs(points) do
        local idx = (i - 1)*DIM
        for i=1,DIM do
            spline.ctrlp[idx + i - 1] = v[i]
        end
    end

    for i, v in ipairs(knots) do
        spline.knots[i - 1] = v
    end
end

function NURBS:coords()
    return function(t)
    end
end


return NURBS
