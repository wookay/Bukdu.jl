# module Bukdu.Plug.OAuth2

module Client

export get_authorize, post_access_token

import ..OAuth2: Provider, authorize_uri, access_token_uri
import URIParser: escape
import Requests
import Requests: URI
import JSON
import ....Bukdu
import Bukdu: redirect_to, Assoc
import Bukdu: Logger

function get_authorize{P<:Provider}(::Type{P}; kw...)
    redirect_to(authorize_uri(P); kw...)
end

function post_access_token{P<:Provider}(::Type{P}; kw...)
    resp = Requests.post(URI(access_token_uri(P)), headers=Dict("Accept"=>"application/json"), data=Dict(kw))
    Assoc(JSON.parse(String(resp.data)))
end

end # module Bukdu.Plug.OAuth2.Client
