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

immutable NoRouteError <: ApplicationError
    conn::Conn
    message::String
end

function reset{AR<:ApplicationRouter}(::Type{AR})
    delete!(Routing.router_routes, AR)
    empty!(Routing.routes)
end

function (::Type{AR}){AR<:ApplicationRouter}(context::Function)
    empty!(Routing.routes)
    context()
    routes = copy(Routing.routes)
    for route in routes
        route.private[:router] = AR
    end
    Routing.router_routes[AR] = routes
    empty!(RouterScope.stack)
    nothing
end

function (::Type{AR}){AR<:ApplicationRouter}(verb::Function, path::String, headers=Assoc(), cookies=Vector{Cookie}(); kw...)
    conn = Conn()
    routes = haskey(Routing.router_routes, AR) ? Routing.router_routes[AR] : Vector{Route}()
    param_data = Assoc([(k, escape(v)) for (k,v) in kw])
    Routing.route_request(conn, Nullable{Type{Endpoint}}(), routes, Base.function_name(verb), path, headers, cookies, param_data) do route
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

function pipe_through(pipe::Pipeline)
    RouterScope.pipe_through(pipe)
end

function redirect_to(url::String; kw...)
    if isempty(kw)
        location = url
    else
        params = join([string(k,'=',escape(v)) for (k,v) in kw], '&')
        uri = URI(url)
        location = string(url, isempty(uri.query) ? '?' : '&', params)
    end
    Conn(:found, Dict("Location"=>location), nothing) # 302
end

include("router/keyword.jl")
include("router/naming.jl")
include("router/route.jl")
include("router/scope.jl")
include("router/resource.jl")
include("router/endpoint.jl")
include("router/error_response.jl")
include("router/routing.jl")
