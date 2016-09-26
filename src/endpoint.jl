# module Bukdu

import Base: reload

abstract ApplicationEndpoint

"""
    Endpoint

Use `Endpoint` to define the plug pipelines.

```julia
Endpoint() do
    plug(Plug.Static, at= "/", from= "public")
    plug(Plug.Logger)
    plug(Router)
end
```
"""
immutable Endpoint <: ApplicationEndpoint
end

module EndpointManagement
import ..Route
endpoint_routes = Dict{Type,Vector{Route}}()
endpoint_contexts = Dict{Type,Function}()
end # module Bukdu.EndpointManagement


function reload{AE<:ApplicationEndpoint}(::Type{AE})
    context = EndpointManagement.endpoint_contexts[AE]
    empty!(RouterRoute.routes)
    context()
    EndpointManagement.endpoint_routes[AE] = copy(RouterRoute.routes)
    nothing
end

function (::Type{AE}){AE<:ApplicationEndpoint}(context::Function)
    empty!(RouterRoute.routes)
    context()
    EndpointManagement.endpoint_routes[AE] = copy(RouterRoute.routes)
    EndpointManagement.endpoint_contexts[AE] = context
    nothing
end

function (::Type{AE}){AE<:ApplicationEndpoint}(path::String)
    routes = haskey(EndpointManagement.endpoint_routes,AE) ? EndpointManagement.endpoint_routes[AE] : Vector{Route}()
    Routing.request(routes, |, path, Assoc()) do route
        true
    end
end
