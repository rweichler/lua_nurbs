GRAPH = require 'lua.graph'

local BSPLINE = GRAPH()

function BSPLINE:new()
    local self = GRAPH.new(self)

    return self
end

local DIM = 4
function BSPLINE:init()
    local points = self.points
    local knots = self.knots
    assert(self.degree)
    assert(points)
    assert(knots)

    local please = #points + self.degree + 1 == #knots
    if not please then
        print("KNOTS ARNT ADDING UP!!")
        print("#points = "..#points)
        print("degree = "..self.degree)
        print("#knots = "..#knots)
        error("lol")
    end


    if self.c_shit then
        BSPLINE_FREE(self.c_shit[1], self.c_shit[2])
    end

    self.c_shit = {BSPLINE_SETUP(#points, #knots, DIM, points, knots)}
end

function BSPLINE:coords()
    if not self.points and not self.knots and not self.c_shit then return end
    local first = self.knots[self.degree + 1]
    local last = self.knots[#self.knots - self.degree]
    local span = last - first
    local EVALUATE_SPLINE = EVALUATE_SPLINE
    local spline = self.spline

    local points = self.c_shit[1]
    local knots = self.c_shit[2]
    return function(t)
        local u = t*span + first
        local x, y, z, w = BSPLINE_EVAL(points, knots, #self.points, #self.knots, DIM, u, self.degree)
        return x/w, y/w, z/w
    end
end


return BSPLINE
