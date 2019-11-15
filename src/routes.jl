# module Bukdu

export routes

export get, post, delete, patch, put
import Base: get
using .System: HaltedError, NotApplicableError, InternalError, SystemController, internal_error, halted_error, not_applicable

struct DirectRequest
    _req
end

const server_info = string("Bukdu/", BUKDU_VERSION)
const routing_verbs = [:get, :post, :delete, :patch, :put, :options]

# HTTP.URIs: queryparams
# HTTP.jl - URIs.jl
function queryparams(q::AbstractString)
    Dict(Deps.HTTP.URIs.unescapeuri(k) => Deps.HTTP.URIs.unescapeuri(v)
        for (k,v) in ([split(e, "=")..., ""][1:2]
            for e in split(q, "&", keepempty=false)))
end

function fetch_query_params(req::Deps.Request)::Vector{Pair{String,Any}}
    params = queryparams(Deps.HTTP.URIs.URI(req.target).query)
    collect(params)
end

function parsed_path_params(route::Route)::Vector{Pair{String,Any}}
    if isempty(route.param_types)
        route.path_params
    else
        map(route.path_params) do (name, val)
            typ = get(route.param_types, Symbol(name), String)
            Pair{String,Any}(name, typ === String ? val : parse(typ, val))
        end
    end
end

function _build_conn_and_pipelines(route::Route, req::Deps.Request)
    body_params = Plug.ContentParsers.fetch_body_params(route, req)
    query_params = fetch_query_params(req)
    path_params = parsed_path_params(route)
    params = merge(body_params, query_params, path_params)
    halted = false
    conn = Conn(req, Assoc.((body_params, query_params, path_params, params))..., halted)
    for pipefunc in route.pipelines
        pipefunc(conn)
        halted = conn.halted
        halted && break
    end
    if halted
        err = HaltedError("halted on pipelines")
        rou = Route(SystemController, halted_error, route.param_types, route.path_params, route.pipelines)
        obj = halted_error(SystemController(conn, err))
        (rou, obj)
    else
        controller = route.C(conn)
        if applicable(route.action, controller)
            ret = route.action(controller)
            if "HEAD" === req.method
                req.response.status = 301 # 301 Moved Permanently
                push!(req.response.headers, Pair("Content-Length", "0"))
                (route, nothing)
            else
                if ret isa Render
                    obj = ret
                else
                    obj = render(Julia, ret)
                end
                (route, obj)
            end
        else
            err = NotApplicableError(string(route.action, "(::", route.C, ")"))
            rou = Route(SystemController, not_applicable, route.param_types, route.path_params, route.pipelines)
            obj = not_applicable(SystemController(conn, err))
            (rou, obj)
        end
    end
end

function _catch_internal_error(block, route, req)
    try
        block(route, req)
    catch ex
        stackframes = stacktrace(catch_backtrace())
        err = InternalError(ex, stackframes)
        conn = Conn(req)
        rou = Route(SystemController, internal_error, route.param_types, route.path_params, route.pipelines)
        obj = internal_error(SystemController(conn, err))
        (rou, obj)
    end
end

function _proc_request(route::Route, req::Deps.Request)
    System.catch_request(route, req)           # System
    req.response.status = 200
    _catch_internal_error(route, req) do route, req
    # begin #
        _build_conn_and_pipelines(route, req)
    end
end

function _proc_response(route::Route, req::Deps.Request)
    Plug.Loggers.info_response(req, (controller=route.C, action=route.action))
    System.catch_response(route, req.response) # System
end

function put_response_header_and_body(req::Deps.Request, obj)
    push!(req.response.headers, Pair("Server", server_info))
    if obj isa Render
        push!(req.response.headers, Pair("Content-Type", obj.content_type))
        body = Vector{UInt8}(obj.writer(obj.data))
        push!(req.response.headers, Pair("Content-Length", string(length(body))))
        req.response.body = body
    end
end

function request_handler(route::Route, dreq::DirectRequest)::NamedTuple{(:got, :resp, :route)}
    request_handler(route, dreq._req)
end

function request_handler(route::Route, req::Deps.Request)::NamedTuple{(:got, :resp, :route)}
    (rou, obj) = _proc_request(route, req)
    put_response_header_and_body(req, obj)
    _proc_response(rou, req)
    (got=obj isa Render ? obj.data : obj, resp=req.response, route=rou)
end

"""
    routes(block::Function)
"""
function routes(block::Function)
    block()
end

"""
    routes(block::Function, pipe::Symbol)
"""
function routes(block::Function, pipe::Symbol)
    Routing.store[:pipe] = pipe
    block()
    Routing.store[:pipe] = nothing
end


"""
    get(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...)
"""
function get
end

"""
    post(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...)
"""
function post
end

"""
    delete(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...)
"""
function delete
end

"""
    patch(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...)
"""
function patch
end

"""
    put(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...)
"""
function put
end

function head
end

"""
    options(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...)
"""
function options
end

for verb in routing_verbs
    @eval ($verb)(url::String, C::Type{<:ApplicationController}, action, param_types::Pair{Symbol,DataType}...) = Routing.add_route($verb, url, C, action, Dict{Symbol,DataType}(param_types...))
end

for (verb, action) in [(:get, :index), (:post, :create)]
    @eval function ($verb)(f::Function, url::String, param_types::Pair{Symbol,DataType}...)
        $action(c::System.AnonymousController) = f(c.conn)
        Routing.add_route($verb, url, System.AnonymousController, $action, Dict{Symbol,DataType}(param_types...))
    end
end

# module Bukdu
