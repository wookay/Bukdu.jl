module Router # Bukdu

using ..Bukdu.Naming
using ..Bukdu.Deps
using ..Bukdu.Routing
using ..Bukdu: DirectRequest, request_handler

"""
    Router.call

To get the object of the action without going through HTTP server.
Results are named tuple `(got= , resp= , route= )`.
"""
function call
end

"""
    Router.call(verb, path::String, headers=[], body=UInt8[])::NamedTuple{(:got, :resp, :route)}
"""
function call(verb, path::String, headers=[], body=UInt8[])::NamedTuple{(:got, :resp, :route)}
    method = Naming.verb_name(verb)
    req = Deps.Request(method, path, headers, body)
    call(req)
end

"""
    Router.call(req::Deps.Request)::NamedTuple{(:got, :resp, :route)}
"""
function call(req::Deps.Request)::NamedTuple{(:got, :resp, :route)}
    route = Routing.handle(req)
    dreq = DirectRequest(req)
    request_handler(route, dreq)
end


module Helpers # Bukdu.Router

using ...Bukdu.Routing
using ...Bukdu: ApplicationController

struct URLPathError <: Exception
    msg
end

function url_path(verb, C::Type{<:ApplicationController}, action)
    path = Routing.route_path(verb, C, action)
    if path isa Nothing
        URLPathError(string("failed to get the path: ", join([verb, C, action], ' ')))
    else
        path
    end
end

end # module Bukdu.Router.Helpers

end # module Bukdu.Router
