# module Bukdu

export routes

export get, post, delete, patch, put
import Base: get

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

const routing_verbs = [:get, :post, :delete, :patch, :put]

const controller_rpad  = 20
const action_rpad      = 16
const target_path_rpad = 28

function _regularize_text(str::String, padding::Int)::String
    s = escape_string(str)
    if textwidth(s) < padding
        padded_str = rpad(s, padding)
        if textwidth(padded_str) > padding
        else
            return s
        end
    end
    n = 0
    a = []
    for (idx, x) in enumerate(s)
        n += textwidth(x)
        if n > padding - 2
            break
        end
        push!(a, x)
    end
    newstr = join(a)
    newpad = padding - textwidth(newstr)
    if newpad >= 2
        news = string(newstr, "..")
    elseif newpad == 1
        news = string(newstr, ".")
    else
        news = newstr
    end
    npad = padding - textwidth(news)
    rstrip(string(news, npad > 0 ? join(fill(' ', npad)) : ""))
end

function _unescape_req_target(req)
    str = req.target
    try
        str = HTTP.URIs.unescapeuri(req.target)
    catch
    end
    _regularize_text(str, target_path_rpad)
end

function req_method_color(method::String)
    bold = false
    if "POST" == method
        color = :yellow
    else
        color = :cyan
    end
    (bold=bold, color=color)
end

function info_request(action, C::Type{<:ApplicationController}, req)
    logger = Base.global_logger()
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
    printstyled(iob, "INFO:  ", color=:cyan)
    printstyled(iob, rpad(req.method, 6); req_method_color(req.method)...)
    printstyled(iob, string(' ', 
                            rpad(nameof(C), controller_rpad),
                            rpad(nameof(action), action_rpad)
    ))
    printstyled(iob, req.response.status, color= 200 == req.response.status ? :normal : :red)
    printstyled(iob, ' ', _unescape_req_target(req))
    println(iob)
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
end

struct InternalError <: Exception
    msg::String
end

mutable struct DirectResponse
    status
    body
end

mutable struct DirectRequest
    req
    method
    target
    response::DirectResponse
end

function catch_internal_error(block, ureq)
    try
        block()
    catch ex
        err = InternalError(string(ex))
        ureq.response.status = 500
        msg = string(InternalError, ' ', err.msg, '\n', stacktrace(catch_backtrace()))
        if ureq isa DirectRequest
            ureq.response.body = msg
        else
            data = unsafe_wrap(Vector{UInt8}, msg)
            push!(ureq.response.headers, Pair("Content-Type", "text/html; charset=utf-8"))
            ureq.response.body = data
        end
    end
end

function request_handler(route::Routing.Route, ureq::Union{DirectRequest,HTTP.Messages.Request})
    C = route.C
    C === Routing.MissingController && (ureq.response.status = 404)
    action = route.action
    Runtime.catch_request(action, C, ureq) #
    catch_internal_error(ureq) do
    # begin
        req = ureq isa HTTP.Messages.Request ? ureq : ureq.req
        query_params::Vector{Pair{String,String}} = collect(HTTP.queryparams(HTTP.URI(req.target)))
        body_params = FormData.form_data_body_params(req)
        path_params = route.path_params
        params = merge(query_params, body_params, path_params)
        conn = Conn(req, Assoc.((params, query_params, body_params, path_params))...)
        c = C(conn)
        for pip in route.pipelines
            pip(c)
        end
        obj = action(c)
        if ureq isa DirectRequest
            ureq.response.body = obj
        else
            if obj isa Render
                data = obj.body
                push!(ureq.response.headers, Pair("Content-Type", obj.content_type))
            else
                data = unsafe_wrap(Vector{UInt8}, string(obj))
            end
            ureq.response.body = data
        end
    end
    info_request(action, C, ureq)
    Runtime.catch_response(action, C, ureq.response) #
    ureq.response
end

for verb in routing_verbs
    @eval ($verb)(url::String, C::Type{<:ApplicationController}, action) = Routing.add_route($verb, url, C, action)
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
    Routing.context[:pipe] = pipe
    block()
    Routing.context[:pipe] = nothing
end

# module Bukdu
