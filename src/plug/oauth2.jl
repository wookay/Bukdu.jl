# module Bukdu.Plug

module OAuth2

export authorize_uri, access_token_uri
import Compat: @compat

@compat abstract type Provider end

function authorize_uri{P<:Provider}(::Type{P})
end

function access_token_uri{P<:Provider}(::Type{P})
end

include("oauth2/controller.jl")
include("oauth2/client.jl")
include("oauth2/providers.jl")

end # Bukdu.Plug.OAuth2
