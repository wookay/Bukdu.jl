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
import Bukdu: parse_cookie_string, conn_bad_request
import Bukdu: Logger
import URIParser: URI
import HttpCommon: Cookie, parsequerystring

const SLASH = '/'
const COLON = ':'

task_storage = Dict{Task,Conn}()
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

function trail(s::String, n)
    length(s) > n > 2 ? string(s[1:n-2], "..") : s
end

function debug_verb(verb::Symbol, path)
    verb = lpad(uppercase(string(verb)), 4)
    path_pad = Logger.settings[:path_padding]
    trailed_path = trail(path, path_pad)
    rpaded_path = Logger.with_color(:bold, rpad(trailed_path, path_pad))
    verb, rpaded_path
end

function debug_route{AC<:ApplicationController}(route::Route, verb::Symbol, path::String, ::Type{AC})
    tuple(debug_verb(verb, path)..., "$(Base.function_name(route.action))(::$AC)")
end

function error_route(verb::Symbol, path::String, ex, callstack)
    tuple(
        debug_verb(verb, path)...,
        '\n',
        Logger.with_color(:red, ex),
        callstack)
end

function request{AE<:ApplicationEndpoint}(compare::Function, endpoint::Nullable{Type{AE}}, routes::Vector{Route}, verb::Symbol, path::String, headers::Assoc, cookies::Vector{Cookie}, param_data::Assoc)::Conn
    uri = URI(path)
    reqsegs = split(uri.path, SLASH)
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
            rousegs = split(route.path, SLASH)
            if :match == route.kind
                if length_reqsegs == length(rousegs)
                    matched = all(enumerate(rousegs)) do idx_rouseg
                        (idx,rouseg) = idx_rouseg
                        startswith(rouseg, COLON) ? true : reqsegs[idx]==rouseg
                    end
                end
            elseif :matchall == route.kind
                matched = startswith(path, route.path)
            end
            if matched
                function startswithcolon(idx_rouseg)
                    (idx,rouseg) = idx_rouseg
                    startswith(rouseg, COLON)
                end
                params = Assoc(map(filter(startswithcolon, enumerate(rousegs))) do idx_rouseg
                    (idx,rouseg) = idx_rouseg
                    (Symbol(replace(rouseg, r"^:", "")),String(reqsegs[idx]))
                end)
                C = route.controller
                controller = C()
                query_params = Assoc(parsequerystring(uri.query))
                if !isempty(param_data)
                    merge!(query_params, param_data)
                end
                conn = Conn()
                ## Request fields - host, method, path, req_headers, scheme
                conn.host = uri.host
                conn.method = verb
                conn.path = path
                conn.req_headers = headers
                conn.scheme = uri.scheme
                ## Fetchable fields - req_cookies, query_params, params
                conn.req_cookies = cookies
                conn.query_params = query_params
                conn.params = params
                ## Connection fields - assigns, halted, state
                conn.assigns = copy(route.assigns)
                ## Private fields - private
                conn.private = copy(route.private)
                conn.private[:action] = route.action
                conn.private[:controller] = controller
                conn.private[:endpoint] = isnull(endpoint) ? nothing : endpoint.value
                task = current_task()
                task_storage[task] = conn
                for pipe in route.pipes
                    pipe(conn)
                end
                if method_exists(before, (C,))
                    before(controller)
                end
                result = nothing
                try
                    Logger.debug() do
                        debug_route(route, verb, path, C)
                    end
                    result = route.action(controller)
                catch ex
                    stackframes = stacktrace(catch_backtrace())
                    Logger.error() do
                        error_route(verb, path, ex, stackframes)
                    end
                    result = conn_bad_request(verb, path, ex, stackframes)
                end
                if method_exists(after, (C,))
                    after(controller)
                end
                pop!(task_storage, task)
                ## Response fields - resp_body, resp_charset, resp_cookies, resp_headers, status, before_send
                if isa(result, Conn)
                    conn.status = result.status
                    conn.resp_headers = result.resp_headers
                    conn.resp_body = result.resp_body
                else
                    conn.status = 200 # :ok
                    conn.resp_body = result
                end
                return conn
            end
        end
    end
    Logger.warn() do
        debug_verb(verb, path)
    end
    throw(Bukdu.NoRouteError(path))
end

end # module Bukdu.Routing
