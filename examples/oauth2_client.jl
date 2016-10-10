importall Bukdu
import Plug.OAuth2
import Plug.OAuth2: authorize_uri, access_token_uri
import Plug.OAuth2: Github, Facebook, Slack # providers

type Custom <: OAuth2.Provider
end

provider = Custom # Github Slack Facebook

authorize_uri(::Type{Custom}) = "http://localhost:8086/login/oauth/authorize"
access_token_uri(::Type{Custom}) = "http://localhost:8086/login/oauth/access_token"

callback_path(::Type{Github}) = "/oauth2/github/callback"
callback_path(::Type{Facebook}) = "/oauth2/facebook/callback"
callback_path(::Type{Slack}) = "/oauth2/slack/callback"
callback_path(::Type{Custom}) = "/oauth2/custom/callback"

oauth_scopes(::Type{Github}) = "public_repo"
oauth_scopes(::Type{Facebook}) = "public_profile"
oauth_scopes(::Type{Slack}) = "chat:write:bot"
oauth_scopes(::Type{Custom}) = "public_repo"

state_for_csrf = string(Base.Random.uuid1())

auth_scope = oauth_scopes(provider)
provider_name = uppercase(string(provider.name.name))
client_id = ENV["$(provider_name)_CLIENT_ID"]
client_secret = ENV["$(provider_name)_CLIENT_SECRET"]

authorization_code = nothing
authorization_callback_uri = "https://localhost:8085$(callback_path(provider))"

callbacked = []

type TestOAuth2Controller{P<:OAuth2.Provider} <: ApplicationController
end

function index(::TestOAuth2Controller)
    authorized = !isa(authorization_code, Void)
    render(Markdown, """
# $provider
```
$callbacked
```

[oauth_authorize](/oauth_authorize)
$authorized
[oauth_access_token](/oauth_access_token)
    """)
end

function callback{P<:OAuth2.Provider}(c::TestOAuth2Controller{P})
    Logger.info("callback", P)
    params = c[:query_params]
    if haskey(params, :state) && haskey(params, :code)
        if params[:state] == state_for_csrf
            global authorization_code = params[:code]
            push!(callbacked, string(authorization_code[1:5], "..."))
            redirect_to("/")
        end
    else
        push!(callbacked, params[:error])
        redirect_to("/")
    end
end

function oauth_authorize(::TestOAuth2Controller)
    OAuth2.Client.get_authorize(provider,
        client_id = client_id,
        scope = auth_scope,
        response_type = "code",
        redirect_uri = authorization_callback_uri,
        state = state_for_csrf)
end

function oauth_access_token(::TestOAuth2Controller)
    assoc = OAuth2.Client.post_access_token(provider,
        client_id = client_id,
        client_secret = client_secret,
        scope = auth_scope,
        code = authorization_code,
        redirect_uri = authorization_callback_uri,
        state = state_for_csrf)
    if haskey(assoc, :error)
        if haskey(assoc, :error_uri)
            error_uri = assoc[:error_uri]
            error_link = "- [$error_uri]($error_uri)"
        else
            error_link = ""
        end
        render(Markdown, """
# $(assoc[:error])
  $(assoc[:error_description])
$error_link
        """)
    else
        [(k, k==:access_token ? string(v[1:5], "...") : v) for (k,v) in assoc]
    end
end

Router() do
    for p in [Custom, Github, Facebook, Slack]
        get("/", TestOAuth2Controller{p}, index)
        get("/oauth_authorize", TestOAuth2Controller{p}, oauth_authorize)
        get("/oauth_access_token", TestOAuth2Controller{p}, oauth_access_token)
        get(callback_path(p), TestOAuth2Controller{p}, callback)
    end
end

Endpoint() do
    plug(Plug.Logger)
    plug(Plug.CSRFProtection)
    plug(Router)
end


rel(p::String) = joinpath(dirname(@__FILE__), p)
if !isfile(rel("keys/server.crt"))
    @static if is_unix()
        run(`mkdir -p $(rel("keys"))`)
        run(`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout
            $(rel("keys/server.key")) -out $(rel("keys/server.crt"))`)
    end
end
cert = MbedTLS.crt_parse_file(rel("keys/server.crt"))
key = MbedTLS.parse_keyfile(rel("keys/server.key"))
Bukdu.start(8085, ssl=(cert,key))

(Endpoint)("/")
Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
