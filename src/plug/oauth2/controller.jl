# module Bukdu.Plug.OAuth2

export OAuthController
export authorize_path, access_token_path
export get_authorize, post_authorize, post_access_token

import ....Bukdu: ApplicationController, ApplicationRouter, Conn, plug, get, post
import ....Bukdu: Logger

struct OAuthController{P<:OAuth2.Provider} <: ApplicationController
    conn::Conn
end

function authorize_path
end

function access_token_path
end

function get_authorize
end

function post_authorize
end

function post_access_token
end

struct OAuth2Router <: ApplicationRouter
end

function plug{P<:Provider}(::Type{Provider}, ::Type{P}; kw...)
    OAuth2Router() do
        get(authorize_path(P), OAuthController{P}, get_authorize)
        post(authorize_path(P), OAuthController{P}, post_authorize)
        post(access_token_path(P), OAuthController{P}, post_access_token)
    end
    plug(OAuth2.OAuth2Router)
end
