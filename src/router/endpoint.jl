# module Bukdu

import Base: reload

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

function has_called{AE<:ApplicationEndpoint}(::Type{AE})
    haskey(Routing.runtime, AE)
end

function (::Type{AE}){AE<:ApplicationEndpoint}(context::Function)
    empty!(RouterRoute.routes)
    context()
    EndpointManagement.endpoint_routes[AE] = copy(RouterRoute.routes)
    EndpointManagement.endpoint_contexts[AE] = context
    Routing.runtime[AE] = true
    nothing
end

function (::Type{AE}){AE<:ApplicationEndpoint}(path::String, args...; kw...)
    routes = haskey(EndpointManagement.endpoint_routes,AE) ? EndpointManagement.endpoint_routes[AE] : Vector{Route}()
    data = Assoc()
    if !isempty(args) || !isempty(kw)
        data = Assoc(map(vcat(args..., kw...)) do kv
            (k,v) = kv
            (k, escape(v))
        end)
    end
    Routing.request(routes, |, path, Assoc(), data) do route
        true
    end
end
