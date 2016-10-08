# module Bukdu.Plug

import ....Bukdu
import Bukdu: Conn, Pipeline
import Bukdu.RouterScope: pipe_through

immutable CSRFProtection
end

immutable InvalidCSRFTokenError
    message
end

const unprotected_methods = [:head, :get, :options]

function check_csrf_token(conn::Conn)
    conn.method in unprotected_methods && return
    if haskey(conn.query_params, :_csrf_token)
        token = conn.query_params[:_csrf_token]
        if haskey(conn.req_cookies, Plug.bukdu_cookie_id)
            cook = conn.req_cookies[Plug.bukdu_cookie_id]
            if Plug.SessionData.has_cookie(cook)
                dict = Plug.SessionData.get_cookie(cook)
                if token == dict["_csrf_token"]
                    Plug.SessionData.delete_cookie(cook)
                    return true
                end
            end
        end
    end
    throw(InvalidCSRFTokenError("Cross Site Request Forgery"))
end

function plug(::Type{Plug.CSRFProtection}; kw...)
    pipe_through(Pipeline(check_csrf_token))
end

function protect_from_forgery(conn::Conn)
    plug(Plug.CSRFProtection)
end

function generate_token()::Base.Random.UUID
    Base.Random.uuid1()
end

function get_csrf_token(conn::Conn)::Base.Random.UUID
    if !haskey(conn.assigns, :csrf_token)
        conn.assigns[:csrf_token] = generate_token()
    end
    conn.assigns[:csrf_token]
end

function delete_csrf_token(conn::Conn)
    delete!(conn.assigns, :csrf_token)
end

function csrf_token(conn::Conn)
    token = get_csrf_token(conn)
    conn.resp_cookies["_csrf_token"] = string(token)
end
