# module Bukdu.Plug.OAuth2

immutable Facebook <: Provider
end

authorize_uri(::Type{Facebook}) = "https://www.facebook.com/dialog/oauth"
access_token_uri(::Type{Facebook}) = "https://graph.facebook.com/oauth/access_token"

function post_access_token(P::Type{Facebook}; kw...)
    resp = Requests.post(access_token_url(P), data=Dict(kw))
    Assoc(parsequerystring(String(resp.data)))
end
