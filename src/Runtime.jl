# module Bukdu

module Runtime

import ..Routing

"""
    Bukdu.Runtime.catch_request(route::Route, req)
"""
function catch_request
end

"""
    Bukdu.Runtime.catch_response(route::Route, resp)
"""
function catch_response
end

end # module Bukdu.Runtime



function Bukdu.Runtime.catch_request(route::Route, req)
#    @debug "REQ " req.headers
end

function Bukdu.Runtime.catch_response(route::Route, resp)
#    @debug "RESP" resp.headers String(resp.body)
end

# module Bukdu
