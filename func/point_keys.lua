local DELTA = DELTA/4


local keyfuncs = {}
keyfuncs.w = function(pt)
    pt.z = pt.z + DELTA
end
keyfuncs.a = function(pt)
    pt.x = pt.x - DELTA
end
keyfuncs.s = function(pt)
    pt.z = pt.z - DELTA
end
keyfuncs.d = function(pt)
    pt.x = pt.x + DELTA
end
keyfuncs.r = function(pt)
    pt.y = pt.y + DELTA
end
keyfuncs.f = function(pt)
    pt.y = pt.y - DELTA
end
return keyfuncs
