# module Bukdu

export Router

export get, post, delete, patch, put
import Base: get


const env = Dict{Symbol, Any}(
    :server => nothing,
)

struct Router <: ApplicationRouter
end

function post
end

function delete
end

function patch
end

function put
end

const routing_verbs = [get, post, delete, patch, put]

const action_rpad      = 13
const controller_rpad  = 20
const target_path_rpad = 26

import Unicode # Unicode.graphemes
function _unescape_req_target(req)
    s = HTTP.URIs.unescapeuri(req.target)
    a = Unicode.graphemes(s)
    ifelse(length(a) > target_path_rpad, join(a), s)
end

function info_request(action, C::Type{<:ApplicationController}, req)
    @info req.method rpad(nameof(action), action_rpad) rpad(nameof(C), controller_rpad) req.response.status _unescape_req_target(req)
end

function warn_missing(req)
    @warn req.method rpad(missing, action_rpad)        rpad(" ", controller_rpad)       req.response.status _unescape_req_target(req)
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

function request_handler(route::Routing.Route, req::Union{DirectRequest,HTTP.Messages.Request})
    C = route.C
    action = route.action
    Runtime.catch_request(action, C, req) #
    try
        conn = Conn(route.path_params, req isa HTTP.Messages.Request ? req : req.req)
        c = C(conn)
        obj = action(c)
        if req isa DirectRequest
            req.response.body = obj
        else
            if obj isa Render
                data = obj.body
                push!(req.response.headers, Pair("Content-Type", obj.content_type))
            else
                data = unsafe_wrap(Vector{UInt8}, string(obj))
            end
            req.response.body = data
        end
    catch ex
        err = InternalError(string(ex))
        req.response.status = 404
        if req isa DirectRequest
            req.response.body = err
        else
            data = unsafe_wrap(Vector{UInt8}, string(InternalError, ' ', err.msg))
            push!(req.response.headers, Pair("Content-Type", "text/html; charset=utf-8"))
            req.response.body = data
        end
    end
    info_request(action, C, req)
    Runtime.catch_response(action, C, req.response) #
    req.response
end

function get(url::String, C::Type{<:ApplicationController}, action)
    Routing.add_route(get, url, C, action)
end

function Router(f)
    f()
end

function (::Type{R})(verb, path::String) where {R <: ApplicationRouter}
    method = Naming.verb_name(verb)
    req = HTTP.Messages.Request(method, path)
    route = Routing.handle(req)
    dreq = DirectRequest(req, req.method, req.target, DirectResponse(200, nothing))
    response = request_handler(route, dreq)
    response.body
end

# module Bukdu
