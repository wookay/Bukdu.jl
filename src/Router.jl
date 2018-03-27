module Router # Bukdu

import ..Bukdu: Naming, Routing, DirectRequest, DirectResponse, request_handler
import ..Bukdu: HTTP

"""
    Router.request(verb, path::String)
"""
function request(verb, path::String)
    method = Naming.verb_name(verb)
    req = HTTP.Messages.Request(method, path)
    route = Routing.handle(req)
    dreq = DirectRequest(req, req.method, req.target, DirectResponse(200, nothing))
    response = request_handler(route, dreq)
    response.body
end


module Helpers # Bukdu.Router

import ...Bukdu: ApplicationController, Routing

function url_path(verb, C::Type{<:ApplicationController}, action)
    Routing.route_path(verb, C, action)
end

end # module Bukdu.Router.Helpers

end # module Bukdu.Router
