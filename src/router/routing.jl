# module Bukdu

module Routing

import ..Bukdu
import Bukdu: ApplicationController, ApplicationEndpoint, ApplicationRouter
import Bukdu: Endpoint, Router
import Bukdu: Route, RouterScope, RouterResource, Resource
import Bukdu: Assoc, Conn
import Bukdu: index, edit, new, show, create, update, delete
import Bukdu: get, post, delete, patch, put
import Bukdu: before, after
import Bukdu: put_status, parse_cookie_string, conn_bad_request
import Bukdu: NoRouteError
import Bukdu: Logger
import Bukdu.Logger: trail, debug_verb
import URIParser: URI
import HttpCommon: Cookie, parsequerystring
isdefined(Base, :Iterators) && import Base.Iterators: filter

routes = Vector{Route}()
router_routes = Dict{Type,Vector{Route}}() # AR => Vector{Route}
endpoint_routes = Dict{Type,Vector{Route}}() # AE => Vector{Route}
endpoint_contexts = Dict{Type,Function}() # AE => context

# route
function match{AC<:ApplicationController}(verb::Function, path::String, ::Type{AC}, action::Function, options::Dict)
    add_route(:match, verb, path, AC, action, options)
end

function matchall{AC<:ApplicationController}(verb::Function, path::String, ::Type{AC}, action::Function, options::Dict)
    add_route(:matchall, verb, path, AC, action, options)
end

function add_route{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String, ::Type{AC}, action::Function, options::Dict)
    route = RouterScope.route(kind, verb, path, AC, action, options)
    push!(routes, route)
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
                                        (new,    get,    "/new"),
                                        (edit,   get,    "/:$param/edit"),
                                        (show,   get,    "/:$param"),
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

function debug_route{AC<:ApplicationController}(route::Route, verb::Symbol, path::String, ::Type{AC})
    controller_name = AC.name.name
    tuple(debug_verb(verb, path)..., "$(Base.function_name(route.action))(::$controller_name)")
end

function error_route(verb::Symbol, path::String, ex, callstack)
    tuple(
        debug_verb(verb, path)...,
        '\n',
        Logger.with_color(:red, ex),
        callstack)
end

function squeeze_multiple_slashes(path::String)::String
    replace(path, r"/+", "/")
end

function route_request{AE<:ApplicationEndpoint}(compare::Function, conn::Conn, endpoint::Nullable{Type{AE}}, routes::Vector{Route}, verb::Symbol, path::String, headers::Assoc, cookies::Vector{Cookie}, body_params::Assoc)::Conn # throw NoRouteError
    uri = URI(path)
    uri_path = squeeze_multiple_slashes(uri.path)
    reqsegs = split(uri_path, '/')
    length_reqsegs = length(reqsegs)
    for route in routes
        if compare(route)
            if !isempty(route.host)
                if endswith(route.host, ".")
                    !startswith(uri.host, route.host) && continue
                else
                    !endswith(uri.host, route.host) && continue
                end
            end
            matched = false
            rousegs = split(route.path, '/')
            if :match == route.kind
                if length_reqsegs == length(rousegs)
                    matched = all(enumerate(rousegs)) do idx_rouseg
                        (idx, rouseg) = idx_rouseg
                        startswith(rouseg, ':') ? true : reqsegs[idx]==rouseg
                    end
                end
            elseif :matchall == route.kind
                matched = startswith(uri_path, route.path)
            end
            if matched
                function startswithcolon(idx_rouseg)
                    (idx, rouseg) = idx_rouseg
                    startswith(rouseg, ':')
                end
                C = route.controller
                ## Request fields - host, port, method, path, req_headers, scheme
                conn.host = uri.host
                conn.method = verb
                conn.path = uri_path
                conn.req_headers = headers
                conn.scheme = uri.scheme
                ## Fetchable fields - req_cookies, query_params, body_params, path_params, params
                conn.req_cookies = cookies
                query_params = Assoc(parsequerystring(uri.query))
                path_params = Assoc(map(filter(startswithcolon, enumerate(rousegs))) do idx_rouseg
                    (idx, rouseg) = idx_rouseg
                    (Symbol(replace(rouseg, r"^:", "")), String(reqsegs[idx]))
                end)
                params = Assoc()
                merge!(params, query_params)
                merge!(params, body_params)
                merge!(params, path_params)
                conn.query_params = query_params
                conn.body_params = body_params
                conn.path_params = path_params
                conn.params = params
                ## Connection fields - assigns, halted, state
                conn.assigns = copy(route.assigns)
                ## Private fields - private
                conn.private = copy(route.private)
                conn.private[:action] = route.action
                conn.private[:endpoint] = isnull(endpoint) ? nothing : endpoint.value
                if :conn in fieldnames(C) && (fieldtype(C, :conn) == Conn)
                    controller = C(conn)
                else
                    controller = C()
                end
                conn.private[:controller] = controller
                for pipe in route.pipes
                    if isempty(pipe.only)
                        pipe(conn)
                    else
                        route.action in pipe.only && pipe(conn)
                    end
                end
                applicable(before, controller) && before(controller)
                result = nothing
                try
                    Logger.debug(() -> !in(C, Logger.settings[:hide])) do
                        debug_route(route, verb, path, C)
                    end
                    result = route.action(controller)
                catch ex
                    stackframes = stacktrace(catch_backtrace())
                    Logger.error() do
                        error_route(verb, path, ex, stackframes)
                    end
                    result = conn_bad_request(verb, path, ex, stackframes) # 400
                end
                ## Response fields - resp_body, resp_charset, resp_cookies, resp_headers, status, before_send
                if isa(result, Conn)
                    put_status(conn, result.status)
                    conn.resp_headers = result.resp_headers
                    conn.resp_body = result.resp_body
                else
                    418 == conn.status && put_status(conn, :ok) # :im_a_teapot 418 => :ok 200
                    conn.resp_body = result
                end
                applicable(after, controller) && after(controller)
                return conn
            end
        end
    end
    ex = NoRouteError(conn, string("not found ", path)) # 404
    Logger.warn() do
        debug_verb(verb, path, ex)
    end
    throw(ex)
end

end # module Bukdu.Routing
