importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag
importall Plug.OAuth2

immutable CustomProvider <: OAuth2.Provider
end

authorize_path(::Type{CustomProvider}) = "/login/oauth/authorize"
access_token_path(::Type{CustomProvider}) = "/login/oauth/access_token"
authorize_uri(P::Type{CustomProvider}) = "http://localhost:8086$(authorize_path(P))"
access_token_uri(P::Type{CustomProvider}) = "http://localhost:8086$(access_token_path(P))"

function json_error(error, error_description)
    Conn(400, Dict("Content-Type"=>"application/json"), JSON.json(Dict(
        :error => error,
        :error_description => string(error_description)
    )))
end

function get_authorize(c::OAuthController{CustomProvider})
    error_description = "User does not have access"
    try
        params = c[:query_params]
        return render(HTML, string(
            "<h3>Authorize application</h3>",
            form_for(nothing, action=post_authorize, method=post) do f
                string(
                    hidden_input(f, :redirect_uri, params[:redirect_uri]),
                    hidden_input(f, :state, params[:state]),
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

authorization_callback_url = "https://localhost:8085/oauth2/custom/callback"
authorization_code = nothing

function post_authorize(c::OAuthController{CustomProvider})
    error_description = "User does not have access"
    try
        params = c[:query_params]
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
        params = c[:query_params]
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

Endpoint() do
    plug(Plug.Logger)
    plug(Plug.OAuth2.Provider, CustomProvider)
end


#rel(p::String) = joinpath(dirname(@__FILE__), p)
#if !isfile(rel("keys/server.crt"))
#    @static if is_unix()
#        run(`mkdir -p $(rel("keys"))`)
#        run(`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout
#            $(rel("keys/server.key")) -out $(rel("keys/server.crt"))`)
#    end
#end
#cert = MbedTLS.crt_parse_file(rel("keys/server.crt"))
#key = MbedTLS.parse_keyfile(rel("keys/server.key"))
Bukdu.start(8086) #, ssl=(cert,key))

Logger.set_path_padding(60)

wait()

# Bukdu.stop()
