# module Bukdu

import Base: reset
import URIParser: URI, escape

"""
    Router

Use to route for the incoming path into the controller and action.

Verbs are `get`, `post`, `delete`, `patch`, `put`.

`scope` and `resources` are used to namespace something.

```julia
Router() do
    get("/", WelcomeController, index)
end
```
"""
immutable Router <: ApplicationRouter
end

immutable NoRouteError
    path
end

function reset{AR<:ApplicationRouter}(::Type{AR})
    delete!(Routing.routing_map, AR)
end

function has_called{AR<:ApplicationRouter}(::Type{AR})
    haskey(Routing.runtime, AR)
end

function (::Type{AR}){AR<:ApplicationRouter}(context::Function)
    empty!(RouterRoute.routes)
    context()
    Routing.routing_map[AR] = copy(RouterRoute.routes)
    empty!(RouterScope.stack)
    Routing.runtime[AR] = true
    nothing
end

function (::Type{AR}){AR<:ApplicationRouter}(verb::Function, path::String, args...; kw...)
    routes = haskey(Routing.routing_map, AR) ? Routing.routing_map[AR] : Vector{Route}()
    data = Assoc()
    if !isempty(args) || !isempty(kw)
        data = Assoc(map(vcat(args..., kw...)) do kv
            (k,v) = kv
            (k, escape(v))
        end)
    end
    headers = Assoc()
    Routing.request(routes, verb, path, headers, data) do route
        Base.function_name(route.verb) == Base.function_name(verb)
    end
end

"""
    scope

Scoping around the routes.

```julia
scope("/admin") do
    get("/users/:id", UserController, index)
end
```
"""
function scope(context::Function, path::String; kw...)
    Routing.do_scope(context, merge(Dict(:path=>path), Dict(kw)))
end

function scope(context::Function, path::String, modul::Module; kw...)
    Routing.do_scope(context, merge(Dict(:path=>path), Dict(kw)))
end

function scope(context::Function; kw...)
    Routing.do_scope(context, Dict(kw))
end

"""
    resources

Generating RESTful routes.

```julia
resources("/users", UserController, only= [index])
```
"""
function resources{AC<:ApplicationController}(path::String, ::Type{AC}; kw...)
    Routing.add_resources(()->nothing, path, AC, Dict(kw))
end

function resources{AC<:ApplicationController}(context::Function, path::String, ::Type{AC}; kw...)
    Routing.add_resources(context, path, AC, Dict(kw))
end

function redirect_to(url::String; kw...)
    if isempty(kw)
        location = url
    else
        params = join([string(k,'=',escape(v)) for (k,v) in kw], '&')
        uri = URI(url)
        location = string(url, isempty(uri.query) ? '?' : '&', params)
    end
    Conn(302, Dict("Location"=>location), nothing)
end

include("router/keyword.jl")
include("router/naming.jl")
include("router/conn.jl")
include("router/route.jl")
include("router/scope.jl")
include("router/resource.jl")
include("router/routing.jl")
include("router/endpoint.jl")
