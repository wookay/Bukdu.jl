# module Bukdu

export routes

export get, post, delete, patch, put
import Base: get
using .System: HaltedError, NotApplicableError, InternalError, SystemController, internal_error, halted_error, not_applicable, info_response

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

function fetch_query_params(req::Deps.Request)::Vector{Pair{String,String}}
    params = queryparams(Deps.HTTP.URIs.URI(req.target).query)
    collect(params)
end

function _build_conn_and_pipelines(route::Route, req::Deps.Request)
    body_params = Plug.Parsers.fetch_body_params(req)
    query_params = fetch_query_params(req)
    path_params = route.path_params
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
        rou = Route(SystemController, halted_error, route.path_params, route.pipelines)
        obj = halted_error(SystemController(conn, err))
        (rou, obj)
    else
        controller = route.C(conn)
        if applicable(route.action, controller)
            obj = route.action(controller)
            if "HEAD" === req.method
                (route, nothing)
            else
                (route, obj)
            end
        else
            err = NotApplicableError(string(route.action, "(::", route.C, ")"))
            rou = Route(SystemController, not_applicable, route.path_params, route.pipelines)
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
        rou = Route(SystemController, internal_error, route.path_params, route.pipelines)
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
    info_response(route, req, req.response)
    System.catch_response(route, req.response) # System
end

function put_response_headers(req::Deps.Request, obj)
    push!(req.response.headers, Pair("Server", server_info))
    if obj isa Render
        push!(req.response.headers, Pair("Content-Type", obj.content_type))
        push!(req.response.headers, Pair("Content-Length", string(length(obj.body))))
    end
end

function request_handler(route::Route, dreq::DirectRequest)
    (rou, obj) = _proc_request(route, dreq._req)
    put_response_headers(dreq._req, obj)
    _proc_response(rou, dreq._req)
    (got=obj, resp=dreq._req.response, route=rou)
end

function request_handler(route::Route, req::Deps.Request)
    (rou, obj) = _proc_request(route, req)
    put_response_headers(req, obj)
    if obj isa Render
        data = obj.body
    elseif obj isa Nothing
        data = Vector{UInt8}()
    else
        data = Vector{UInt8}(string(obj))
    end
    req.response.body = data
    _proc_response(rou, req)
    (got=obj, resp=req.response, route=rou)
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
    get(url::String, C::Type{<:ApplicationController}, action)
"""
function get
end

"""
    post(url::String, C::Type{<:ApplicationController}, action)
"""
function post
end

"""
    delete(url::String, C::Type{<:ApplicationController}, action)
"""
function delete
end

"""
    patch(url::String, C::Type{<:ApplicationController}, action)
"""
function patch
end

"""
    put(url::String, C::Type{<:ApplicationController}, action)
"""
function put
end

function head
end

"""
    options(url::String, C::Type{<:ApplicationController}, action)
"""
function options
end

for verb in routing_verbs
    @eval ($verb)(url::String, C::Type{<:ApplicationController}, action) = Routing.add_route($verb, url, C, action)
end

# module Bukdu
