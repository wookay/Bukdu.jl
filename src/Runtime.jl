# module Bukdu

module Runtime

function catch_request
end

function catch_response
end

end # module Bukdu.Runtime



function Bukdu.Runtime.catch_request(action, C::Type{<:ApplicationController}, req)
#    @debug "REQ " req.headers
end

function Bukdu.Runtime.catch_response(action, C::Type{<:ApplicationController}, resp)
#    @debug "RESP" resp.headers String(resp.body)
end

# module Bukdu
