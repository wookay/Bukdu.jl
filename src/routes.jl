# module Bukdu

export resources
export get
export Router

# using HTTP # HTTP.Router HTTP.HandlerFunction HTTP.register! HTTP.Messages.Request

const env = Dict{Symbol, Any}(
    :router => nothing,
    :server => nothing,
)

struct Router
end

function resources(::String, ::Type{C}; only=[], except=[]) where {C <: ApplicationController}
end

const action_rpad      = 8
const controller_rpad  = 18
const target_path_rpad = 26

import Unicode

function rpad_req_target(req)
    s = HTTP.URIs.unescapeuri(req.target)
    a = Unicode.graphemes(s)
    ifelse(length(a) > target_path_rpad, join(a), s)
end

function info_request(action, C::Type{<:ApplicationController}, req)
    @info req.method rpad(action, action_rpad)    rpad(C, controller_rpad)   rpad_req_target(req)
end

function warn_missing(req)
    @warn req.method rpad("missing", action_rpad) rpad(" ", controller_rpad) rpad_req_target(req)
end

struct RenderError <: Exception
    msg::String
end

function request_handler(action, C::Type{<:ApplicationController}, req::HTTP.Messages.Request)
    Runtime.catch_request(action, C, req) #
    info_request(action, C, req)
    c = C(req)
    obj = action(c)
    if obj isa Render
        data = obj.body
        push!(req.response.headers, Pair("Content-Type", obj.content_type))
    elseif obj isa AbstractString
        data = unsafe_wrap(Vector{UInt8}, obj)
    else
        err = RenderError(string("render error with ", obj))
        data = unsafe_wrap(Vector{UInt8}, string(RenderError, ' ', err.msg))
        req.response.status = 404
        push!(req.response.headers, Pair("Content-Type", "text/html; charset=utf-8"))
    end
    req.response.body = data
    Runtime.catch_response(action, C, req.response) #
    req.response
end

function Base.get(url::String, C::Type{<:ApplicationController}, action)
    r = env[:router]
    handler = HTTP.HandlerFunction() do req::HTTP.Messages.Request
        request_handler(action, C, req)
    end
    HTTP.register!(r, "GET", url, handler)
end

function Router(f)
    r = HTTP.Router()
    env[:router] = r
    f()
    missing_handler = HTTP.HandlerFunction() do req
        warn_missing(req)
        req.response
    end
    HTTP.register!(r, "GET", "/*", missing_handler)
end
