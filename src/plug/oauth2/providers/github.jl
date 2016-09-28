# module Bukdu.Plug.OAuth2

immutable Github <: Provider
end

authorize_uri(::Type{Github}) = "https://github.com/login/oauth/authorize"
access_token_uri(::Type{Github}) = "https://github.com/login/oauth/access_token"
