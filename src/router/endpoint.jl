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

function reload{AE<:ApplicationEndpoint}(::Type{AE})
    context = Routing.endpoint_contexts[AE]
    empty!(Routing.routes)
    context()
    Routing.endpoint_routes[AE] = copy(Routing.routes)
    nothing
end

function (::Type{AE}){AE<:ApplicationEndpoint}(context::Function)
    empty!(Routing.routes)
    context()
    Routing.endpoint_routes[AE] = copy(Routing.routes)
    Routing.endpoint_contexts[AE] = context
    nothing
end

function (::Type{AE}){AE<:ApplicationEndpoint}(path::String, headers=Assoc(), cookies=Vector{Cookie}(); kw...)
    param_data = Assoc([(k, escape(v)) for (k,v) in kw])
    routes = haskey(Routing.endpoint_routes, AE) ? Routing.endpoint_routes[AE] : Vector{Route}()
    Routing.request(Nullable{Type{AE}}(AE), routes, Symbol(""), path, headers, cookies, param_data) do route
        true
    end
end
