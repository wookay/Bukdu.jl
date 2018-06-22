# module Bukdu.Plug

import ..ApplicationRouter, ..Routing

"""
plug `Router` to give the routes into the Endpoint.

```julia
Endpoint() do
    plug(Router)
end
```
"""
function plug{AR<:ApplicationRouter}(::Type{AR})
    if haskey(Routing.router_routes, AR)
        append!(Routing.routes, Routing.router_routes[AR])
    end
end
