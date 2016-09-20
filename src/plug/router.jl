# module Bukdu.Plug

import ..ApplicationRouter, ..Routing, ..RouterRoute

"""
plug `Router` to give the routes into the Endpoint.

```julia
Endpoint() do
    plug(Router)
end
```
"""
function plug{AR<:ApplicationRouter}(::Type{AR})
    if haskey(Routing.routing_map, AR)
        append!(RouterRoute.routes, Routing.routing_map[AR])
    end
end
