GRAPH = require 'lua.graph'

local NURBS = GRAPH()

function NURBS:new()
    local self = GRAPH.new(self)

    self.spline = ffi.new("tsBSpline[1]")

    return self
end




function NURBS:init(points, weights, knots)
    local TS_CLAMPED = 1
    ffi.C.ts_bspline_free(self.spline)
    ffi.C.ts_bspline_new(self.degree, 4, #points, TS_CLAMPED, self.spline)
    for i, v in ipairs(points) do
        local idx = (i - 1)*4
        self.spline.ctrlp[idx + 0] = v[1] * weights[i]
        self.spline.ctrlp[idx + 1] = v[2] * weights[i]
        self.spline.ctrlp[idx + 2] = v[3] * weights[i]
        self.spline.ctrlp[idx + 3] = weights[i]
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
