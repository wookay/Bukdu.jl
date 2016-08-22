abstract ApplicationRouter

immutable Router <: ApplicationRouter
end

include("router/route.jl")
include("router/scope.jl")
include("router/resource.jl")
include("router/conn.jl")

import Base: reset

function reset{AR<:ApplicationRouter}(::Type{AR})
    empty!(RouterRoute.routes)
end

function (R::Type{AR}){AR<:ApplicationRouter}(context::Function)
    RouterScope.init()
    context()
end

function (R::Type{AR}){AR<:ApplicationRouter}(action::Function, path::String)
    Routing.request(path) do route
        Base.function_name(route.action) == Base.function_name(action)
    end
end

function scope(context::Function, path::String)
    Routing.do_scope(context, Dict(:path=>path))
end

function resource{AC<:ApplicationController}(path::String, controller::Type{AC})
    Routing.add_resource(()->nothing, path, controller, Dict())
end

function resource{AC<:ApplicationController}(context::Function, path::String, controller::Type{AC})
    Routing.add_resource(context, path, controller, Dict())
end


# from phoenix/lib/phoenix/router.ex
module Routing

import Bukdu: ApplicationController
import Bukdu: RouterRoute
import Bukdu: RouterScope
import Bukdu: RouterResource, Resource
import Bukdu: Conn, CONN_NOT_FOUND
import Bukdu: index, edit, new, show, create, update, delete
import Bukdu: get, post, delete, patch, put
import Bukdu: before, after
import URIParser: URI

const SLASH = '/'
const COLON = ':'

# route
function match{AC<:ApplicationController}(verb::Function, path::String, controller::Type{AC}, action::Function, options::Dict)
    add_route(:match, verb, path, controller, action, options)
end

function add_route{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String, controller::Type{AC}, action::Function, options::Dict)
    route = RouterScope.route(kind, verb, path, controller, action, options)
    push!(RouterRoute.routes, route)
end

# scope
function do_scope(context::Function, options::Dict)
    RouterScope.push_scope!(options)
    context()
    RouterScope.pop_scope!()
end

# resource
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

function request(compare::Function, path::String)::Conn
    uri = URI(path)
    reqsegs = split(uri.path, SLASH)
    length_reqsegs = length(reqsegs)
    for route in RouterRoute.routes
        rousegs = split(route.path, SLASH)
        if compare(route) && length_reqsegs==length(rousegs)
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
                    (replace(rouseg, r"^:", ""),String(reqsegs[idx]))
                end)
                C = route.controller
                controller = C()
                if method_exists(before, (C,))
                    before(controller)
                end
                result = route.action(controller)
                if method_exists(before, (C,))
                    after(controller)
                end
                return isa(result, Conn) ? result : Conn(200, result, params)
            end
        end
    end
    CONN_NOT_FOUND
end

end # module Routing