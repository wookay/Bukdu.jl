export ApplicationRouter, Router
export Route
export Scope, scope
export Resource, resource

abstract ApplicationRouter

type Router <: ApplicationRouter
end

include("router/route.jl")
include("router/scope.jl")
include("router/resource.jl")


# route

function (R::Type{AR}){AR<:ApplicationRouter}(context::Function)
    RouterScope.init()
    context()
end

module Routing
import Bukdu: Route
routes = Vector{Route}()
end # module Routing

const SLASH = '/'
const COLON = ':'
include("router/conn.jl")
function (R::Type{AR}){AR<:ApplicationRouter}(action::Function, path::String)
    reqsegs = split(path, SLASH)
    length_reqsegs = length(reqsegs)
    for route in Routing.routes
        rousegs = split(route.path, SLASH)
        if Base.function_name(route.action)==Base.function_name(action) && length_reqsegs==length(rousegs)
            matched = all(enumerate(rousegs)) do idx_rouseg
                (idx,rouseg) = idx_rouseg
                startswith(rouseg, COLON) ? true : reqsegs[idx]==rouseg
            end
            if matched
                function startswithcolon(idx_rouseg)
                    (idx,rouseg) = idx_rouseg
                    startswith(rouseg, COLON)
                end
                params = Dict(map(filter(startswithcolon, enumerate(rousegs))) do idx_rouseg
                    (idx,rouseg) = idx_rouseg
                    (replace(rouseg, r"^:", ""),reqsegs[idx])
                end)
                data = action(route.controller())
                return Conn(200, data, params)
            end
        end
    end
    Conn(404, "not found", Dict())
end

function match{AC<:ApplicationController}(verb::Function, path::String, controller::Type{AC}, action::Function, options::Dict)
    add_route(:match, verb, path, controller, action, options)
end

function add_route{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String, controller::Type{AC}, action::Function, options::Dict)
    route = RouterScope.route(kind, verb, path, controller, action, options)
    push!(Routing.routes, route)
end


# scope
function do_scope(context::Function, options::Dict)
    RouterScope.push_scope!(options)
    context()
    RouterScope.pop_scope!()
end

function scope(context::Function, path::String)
    do_scope(context, Dict(:path=>path))
end


# VERBS
const HTTP_VERBS = [:get, :post, :delete, :patch, :put]

import Base: get
for verb in HTTP_VERBS
    @eval $verb{AC<:ApplicationController}(path::String, controller::Type{AC}, action::Function; kw...) = match($verb, path, controller, action, Dict(kw))
end


# resource
function resource{AC<:ApplicationController}(path::String, controller::Type{AC})
    add_resource(()->nothing, path, controller, Dict())
end

function resource{AC<:ApplicationController}(context::Function, path::String, controller::Type{AC})
    add_resource(context, path, controller, Dict())
end

function add_resource{AC<:ApplicationController}(context::Function, path::String, controller::Type{AC}, options::Dict)
    scopeopts = Dict(:path=>path)
    RouterScope.push_scope!(scopeopts)

    context()
    resource = RouterResource.build(path, controller, options)
    add_route(resource)

    RouterScope.pop_scope!()
end

function add_route(resource::Resource)
    param = resource.param
    for (action,verb,path) in [(index,  get,    ""),
                               (show,   get,    "/:$param"),
                               (new,    get,    "/new"),
                               (edit,   get,    "/:$param/edit"),
                               (create, post,   ""),
                               (delete, delete, "/:$param"),
                               (update, patch,  "/:$param"),
                               (update, put,    "/:$param")]
        if action in RouterResource.controller_actions
            match(verb, path, resource.controller, action, Dict())
        end
    end
end
