module Router # Bukdu

import ..Bukdu: Naming, Deps, Routing, DirectRequest, request_handler

"""
    Router.call

To get the object of the action without going through HTTP server.
Results are named tuple `(got= , resp= , route= )`.
"""
function call
end

"""
    Router.call(verb, path::String)
"""
function call(verb, path::String)
    method = Naming.verb_name(verb)
    req = Deps.Request(method, path)
    call(req)
end

"""
    Router.call(req::Deps.Request)
"""
function call(req::Deps.Request)
    route = Routing.handle(req)
    dreq = DirectRequest(req)
    request_handler(route, dreq) # (got=, resp=)
end


module Helpers # Bukdu.Router

import ...Bukdu: ApplicationController, Routing

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
