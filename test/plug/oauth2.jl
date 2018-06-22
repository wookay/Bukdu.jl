module test_oauth2

importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag
importall Bukdu.Plug.OAuth2
import JSON
import Base.Test: @test, @test_throws

# oauth2 provider
immutable CustomProvider <: OAuth2.Provider
end

immutable ProviderEndpoint <: ApplicationEndpoint
end

authorize_path(::Type{CustomProvider}) = "/login/oauth/authorize"
access_token_path(::Type{CustomProvider}) = "/login/oauth/access_token"
authorize_uri(P::Type{CustomProvider}) = "http://localhost:$port$(authorize_path(P))"
access_token_uri(P::Type{CustomProvider}) = "http://localhost:$port$(access_token_path(P))"

ProviderEndpoint() do
    plug(Plug.Logger, level=:info)
    plug(Plug.OAuth2.Provider, CustomProvider)
end

Logger.set_level(:error)

port = Bukdu.start(ProviderEndpoint, :any)

function json_error(error, error_description)
    # 400
    Conn(:bad_request, Dict("Content-Type"=>"application/json"), JSON.json(Dict(
        :error => error,
        :error_description => string(error_description)
    )))
end

function get_authorize(c::OAuthController{CustomProvider})
    error_description = "User does not have access"
    try
       params = c[:body_params]
       return render(HTML, string(
           "<h3>Authorize application</h3>",
           form_for(nothing, action=post_authorize, method=post) do f
               string(
                   hidden_input(f, :redirect_uri, value=params[:redirect_uri]),
                   hidden_input(f, :state, value=params[:state]),
                   submit("Authorize application")
               )
           end
           )
       )
    catch ex
        error_description = ex
    end
    json_error("access_denied", error_description)
end

clientport = Bukdu.start(Endpoint, :any)

authorization_callback_url = "http://localhost:$clientport/oauth2/custom/callback"
authorization_code = nothing
state_for_csrf = string(Base.Random.uuid1())

function post_authorize(c::OAuthController{CustomProvider})
    error_description = "User does not have access"
    try
        params = c[:body_params]
        redirect_uri = params[:redirect_uri]
        state_for_csrf = params[:state]
        if redirect_uri==authorization_callback_url
            global authorization_code = "htua-edoc"
            return redirect_to(redirect_uri, code=authorization_code, state=state_for_csrf)
        end
    catch ex
        error_description = ex
    end
    json_error("access_denied", error_description)
end

function post_access_token(c::OAuthController{CustomProvider})
    error_description = "User does not have access"
    try
        params = c[:body_params]
        # check params ...
        if isa(authorization_code, Void)
            return json_error(:bad_verification_code, "The code passed is incorrect or expired.")
        end
        auth_scope = params[:scope]
        return render(JSON, Dict(
            :access_token => "ssecca_nekot",
            :token_type => "bearer",
            :scope => auth_scope
        ))
    catch ex
        error_description = ex
    end
    json_error("access_denied", error_description)
end


conn = (ProviderEndpoint)("/login/oauth/authorize", redirect_uri=authorization_callback_url, state=state_for_csrf)
@test 200 == conn.status

# oauth2 client
type TestOAuth2Controller{P<:OAuth2.Provider} <: ApplicationController
    conn::Conn
end

provider = CustomProvider

callback_path(::Type{CustomProvider}) = "/oauth2/custom/callback"
oauth_scopes(::Type{CustomProvider}) = "public_repo"

auth_scope = oauth_scopes(provider)

authorization_code = nothing
authorization_callback_uri = "https://localhost:$clientport$(callback_path(provider))"

client_id = "client id"
client_secret = "client secret"

function index(::TestOAuth2Controller)
end

function callback{P<:OAuth2.Provider}(c::TestOAuth2Controller{P})
    Logger.info("callback", P)
    params = c[:body_params]
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
    for p in [CustomProvider]
        get("/", TestOAuth2Controller{p}, index)
        get("/oauth_authorize", TestOAuth2Controller{p}, oauth_authorize)
        get("/oauth_access_token", TestOAuth2Controller{p}, oauth_access_token)
        get(callback_path(p), TestOAuth2Controller{p}, callback)
    end
end

Endpoint() do
    plug(Router)
end

conn = (Endpoint)("/oauth_authorize")
@test 302 == conn.status

sleep(0.1)
Bukdu.stop(Endpoint)
Bukdu.stop(ProviderEndpoint)

end # module test_oauth2
