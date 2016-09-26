# module Bukdu

abstract ApplicationRouter

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
    message
end

include("router/route.jl")
include("router/scope.jl")
include("router/resource.jl")
include("router/conn.jl")

import Base: reset
import URIParser: escape

function reset{AR<:ApplicationRouter}(::Type{AR})
    delete!(Routing.routing_map, AR)
end

function (::Type{AR}){AR<:ApplicationRouter}(context::Function)
    empty!(RouterRoute.routes)
    context()
    Routing.routing_map[AR] = copy(RouterRoute.routes)
    empty!(RouterScope.stack)
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
    Routing.request(routes, verb, path, data) do route
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


module Routing

import ..Bukdu: ApplicationController
import ..Bukdu: RouterRoute, Route, RouterScope, RouterResource, Resource, NoRouteError
import ..Bukdu: Logger
import ..Bukdu: Conn, conn_bad_request
import ..Bukdu: index, edit, new, show, create, update, delete
import ..Bukdu: get, post, delete, patch, put
import ..Bukdu: plugins, before, after
import ..Bukdu: Assoc
import URIParser: URI
import HttpCommon: parsequerystring

const SLASH = '/'
const COLON = ':'

immutable Branch
    query_params::Assoc
    params::Assoc
    action::Function
    host::String
    assigns::Dict{Symbol,Any}
end

task_storage = Dict{Task,Branch}()
routing_map = Dict{Type,Vector{Route}}()

# route
function match{AC<:ApplicationController}(verb::Function, path::String, ::Type{AC}, action::Function, options::Dict)
    add_route(:match, verb, path, AC, action, options)
end

function add_route{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String, ::Type{AC}, action::Function, options::Dict)
    route = RouterScope.route(kind, verb, path, AC, action, options)
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
function add_resources{AC<:ApplicationController}(context::Function, path::String, ::Type{AC}, options::Dict)
    resource = RouterResource.build(path, AC, options)
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

function trail(s::String, n)
    length(s) > n > 2 ? string(s[1:n-2], "..") : s
end

function debug_route{AC<:ApplicationController}(route, path, ::Type{AC})
    verb = lpad(Logger.verb_uppercase(route.verb), 4)
    path_pad = 35
    trailed_path = trail(path, path_pad)
    rpaded_path = rpad(Logger.with_color(:bold, trailed_path), path_pad)
    verb, rpaded_path, "$(Base.function_name(route.action))(::$AC)"
end

function error_route(route, path, controller, ex, callstack)
    tuple(
        debug_route(route, path, controller)...,
        '\n',
        Logger.with_color(:red, ex),
        callstack)
end

function request(compare::Function, routes::Vector{Route}, verb::Function, path::String, data::Assoc)::Conn
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
                params = Assoc(map(filter(startswithcolon, enumerate(rousegs))) do idx_rouseg
                    (idx,rouseg) = idx_rouseg
                    (replace(rouseg, r"^:", ""),String(reqsegs[idx]))
                end)
                C = route.controller
                controller = C()
                query_params = Assoc(parsequerystring(uri.query))
                if verb == post && !isempty(data)
                    merge!(query_params, data)
                end
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
                try
                    Logger.debug() do
                        debug_route(route, path, C)
                    end
                    result = route.action(controller)
                catch ex
                    stackframes = stacktrace(catch_backtrace())
                    Logger.error() do
                        error_route(route, path, C, ex, stackframes)
                    end
                    result = conn_bad_request(verb, path, ex, stackframes)
                end
                if method_exists(after, (C,))
                    after(controller)
                end
                pop!(task_storage, task)
                if isa(result, Conn)
                    return Conn(result.status, result.resp_header, result.resp_body, params, query_params, route.private, route.assigns)
                else
                    return Conn(200, Dict{String,String}(), result, params, query_params, route.private, route.assigns)
                end
            end
        end
    end
    Logger.warn() do
        Logger.verb_uppercase(verb), Logger.with_color(:bold, path)
    end
    throw(NoRouteError(""))
end

end # module Bukdu.Routing
