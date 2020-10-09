module Router # Bukdu

using ..Bukdu.Naming
using ..Bukdu.Deps
using ..Bukdu: RouteResponse, handle_request

"""
    Router.call

To get the object of the action without going through HTTP server.
Results are named tuple `(got= , resp= , route= )`.
"""
function call
end

"""
    Router.call(verb, path::String, headers=[], body=UInt8[])::RouteResponse
"""
function call(verb, path::String, headers=[], body=UInt8[])::RouteResponse
    method = Naming.verb_name(verb)
    req = Deps.Request(method, path, headers, body)
    Base.invokelatest(call, req)
end

"""
    Router.call(req::Deps.Request)::RouteResponse
"""
function call(req::Deps.Request)::RouteResponse
    handle_request(req, nothing)
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
