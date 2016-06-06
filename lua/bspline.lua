BSPLINE = OBJECT()

function BSPLINE:new()
    local self = OBJECT.new(self)
    self.dimensions = 4
    return self
end

function BSPLINE:eval(u)
    local k, s = self:find_u(u)

    local uk = self.knots[k]

    local h = self.degree - s
    if h < 0 then h = 0 end

    if s == self.degree + 1 then
        if k == self.degree or k == #self.knots - 1 then
            local from
            if k == self.degree then
                from = 0
            else
                k = (k - s)*self.dimensions
            end
            return self.points[1 + from]
        else
            local from = (k - s)*self.dimensions
            return self.points[2 + from]
        end
    else
        local first = k - self.degree
        local last = k - s
        local N = last - first + 1

        local points = {}

        local start = first*self.dimensions + 1
        for i=start, start + N*self.dimensions do
            table.insert(points, self.points[i])
        end

        local lidx = 0
        local ridx = self.dimensions
        local tidx = N*self.dimensions
        for r=1, h do
            for i=first + r, last do
                local ui = self.knots[i + 1]
                local a = (u - ui)/(self.knots[i + self.degree - r + 2] - ui)
                local a_hat = 1 - a
                for d=0,self.dimensions do
                    lidx = lidx + 1
                    ridx = ridx + 1
                    tidx = tidx + 1

                    points[tidx] = a_hat * points[lidx] + a * points[ridx]
                end
            end
            lidx = lidx + dim
            ridx = ridx + dim
        end
    end
end

function BSPLINE:find_u(u)
    local k = 0
    local s = 0
    for k=0,#self.knots-1 do
        local uk = self.knots[k - 1]
        if u == uk then
            s = s + 1
        elseif u < uk then
            break
        end
    end

    if s > self.degree + 1 then
        error("multiplicity")
    elseif
        k <= self.degree or
        k = #self.knots and s == 0 or
        k > #self.knots - self.degree + s - 1
    then
        error("u is undefined")
    end

    k = k - 1

    return k, s
end

return BSPLINE
