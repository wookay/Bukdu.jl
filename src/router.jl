# module Bukdu

abstract ApplicationRouter

immutable Router <: ApplicationRouter
end

immutable NoRouteError
    message
end

include("router/route.jl")
include("router/scope.jl")
include("router/resource.jl")
include("router/conn.jl")

import Base: reset

function reset{AR<:ApplicationRouter}(R::Type{AR})
    delete!(Routing.routing_map, R)
end

function (R::Type{AR}){AR<:ApplicationRouter}(context::Function)
    empty!(RouterRoute.routes)
    context()
    Routing.routing_map[R] = copy(RouterRoute.routes)
    empty!(RouterScope.stack)
    nothing
end

function (R::Type{AR}){AR<:ApplicationRouter}(verb::Function, path::String)
    routes = haskey(Routing.routing_map, R) ? Routing.routing_map[R] : Vector{Route}()
    Routing.request(routes, verb, path) do route
        Base.function_name(route.verb) == Base.function_name(verb)
    end
end

function scope(context::Function, path::String; kw...)
    Routing.do_scope(context, merge(Dict(:path=>path), Dict(kw)))
end

function scope(context::Function, path::String, modul::Module; kw...)
    Routing.do_scope(context, merge(Dict(:path=>path), Dict(kw)))
end

function scope(context::Function; kw...)
    Routing.do_scope(context, Dict(kw))
end

function resources{AC<:ApplicationController}(path::String, controller::Type{AC}; kw...)
    Routing.add_resources(()->nothing, path, controller, Dict(kw))
end

function resources{AC<:ApplicationController}(context::Function, path::String, controller::Type{AC}; kw...)
    Routing.add_resources(context, path, controller, Dict(kw))
end


module Routing

import ..Bukdu: ApplicationController
import ..Bukdu: RouterRoute, Route, RouterScope, RouterResource, Resource, NoRouteError
import ..Bukdu: Logger
import ..Bukdu: Conn, CONN_NOT_FOUND
import ..Bukdu: index, edit, new, show, create, update, delete
import ..Bukdu: get, post, delete, patch, put
import ..Bukdu: plugins, before, after
import URIParser: URI
import HttpCommon: parsequerystring

const SLASH = '/'
const COLON = ':'

immutable Branch
    query_params::Dict{String,String}
    params::Dict{String,String}
    action::Function
    host::String
    assigns::Dict{Symbol,Any}
end

task_storage = Dict{Task,Branch}()
routing_map = Dict{Type,Vector{Route}}()

# route
function match{AC<:ApplicationController}(verb::Function, path::String, controller::Type{AC}, action::Function, options::Dict)
    add_route(:match, verb, path, controller, action, options)
end

function add_route{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String, controller::Type{AC}, action::Function, options::Dict)
    route = RouterScope.route(kind, verb, path, controller, action, options)
    push!(RouterRoute.routes, route)
    route
end

# scope
function do_scope(context::Function, options::Dict)
    RouterScope.push_scope!(options)
    context()
    RouterScope.pop_scope!()
end

# resources
function add_resources{AC<:ApplicationController}(context::Function, path::String, controller::Type{AC}, options::Dict)
    resource = RouterResource.build(path, controller, options)
    Routing.do_scope(context, resource.member)
    add_route(resource)
end

function add_route(resource::Resource)
    path = resource.path
    options = resource.route
    if resource.singleton
        for (action,verb,routepath) in [(index,  get,    ""),
                                        (show,   get,    ""),
                                        (new,    get,    "/new"),
                                        (edit,   get,    "/edit"),
                                        (create, post,   ""),
                                        (delete, delete, ""),
                                        (update, patch,  ""),
                                        (update, put,    "")]
            if action in RouterResource.controller_actions
                match(verb, string(path,routepath), resource.controller, action, options)
            end
        end
    else
        param = resource.param
        for (action,verb,routepath) in [(index,  get,    ""),
                                        (show,   get,    "/:$param"),
                                        (new,    get,    "/new"),
                                        (edit,   get,    "/:$param/edit"),
                                        (create, post,   ""),
                                        (delete, delete, "/:$param"),
                                        (update, patch,  "/:$param"),
                                        (update, put,    "/:$param")]
            if action in RouterResource.controller_actions
                match(verb, string(path,routepath), resource.controller, action, options)
            end
        end
    end
end

function request(compare::Function, routes::Vector{Route}, verb::Function, path::String)::Conn
    uri = URI(path)
    reqsegs = split(uri.path, SLASH)
    length_reqsegs = length(reqsegs)
    for route in routes
        rousegs = split(route.path, SLASH)
        if compare(route) && length_reqsegs==length(rousegs)
            if !isempty(route.host)
                if endswith(route.host, ".")
                    !startswith(uri.host, route.host) && continue
                else
                    !endswith(uri.host, route.host) && continue
                end
            end
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
                query_params = Dict{String,String}(parsequerystring(uri.query))
                branch = Branch(query_params, params, route.action, uri.host, route.assigns)
                task = current_task()
                task_storage[task] = branch
                if method_exists(plugins, (C,))
                    plugins(controller)
                end
                if method_exists(before, (C,))
                    before(controller)
                end
                result = nothing
                resp_headers = Dict{String,String}()
                try
                    Logger.debug() do
                        padding = length(path) > 4 ? "\t" : "\t\t"
                        uppercase(string(Base.function_name(route.verb))), path, padding, string(typeof(controller), '.', Base.function_name(route.action))
                    end
                    result = route.action(controller)
                catch ex
                    Logger.error() do
                        verb, path, '\n', ex, '\n', route, stacktrace()
                    end
                    result = Conn(400, resp_headers, "bad request $ex", params, query_params, route.private, route.assigns)
                end
                if method_exists(after, (C,))
                    after(controller)
                end
                pop!(task_storage, task)
                return isa(result, Conn) ? result : Conn(200, resp_headers, result, params, query_params, route.private, route.assigns)
            end
        end
    end
    Logger.warn() do
        uppercase(string(Base.function_name(verb))), path
    end
    throw(NoRouteError(""))
end

end # module Bukdu.Routing
