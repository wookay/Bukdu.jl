# module Bukdu.Plug

import ..ApplicationRouter, ..Routing, ..RouterRoute

function plug{AR<:ApplicationRouter}(R::Type{AR})
    if haskey(Routing.routing_map, R)
        append!(RouterRoute.routes, Routing.routing_map[R])
    end
end
