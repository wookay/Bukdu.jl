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

function Base.get(url::String, C::Type{<:ApplicationController}, action)
    r = env[:router]
    handler = HTTP.HandlerFunction() do req::HTTP.Messages.Request
        req.response.body = action(C(req))
        req.response
    end
    HTTP.register!(r, "GET", url, handler)
end

function Router(f)
    r = HTTP.Router()
    env[:router] = r
    f()
    missing_handler = HTTP.HandlerFunction() do req
        @warn "missing " req.target
        req.response
    end
    HTTP.register!(r, "GET", "/*", missing_handler)
end
