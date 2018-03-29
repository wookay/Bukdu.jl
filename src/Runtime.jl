# module Bukdu

module Runtime

import ..Routing

function catch_request
end

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
