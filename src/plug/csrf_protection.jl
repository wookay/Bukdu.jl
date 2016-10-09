# module Bukdu.Plug

import ....Bukdu
import Bukdu: ApplicationError, Conn, Pipeline
import Bukdu: put_status, put_resp_cookie, bukdu_cookie_key
import Bukdu.RouterScope: pipe_through
import HttpCommon: Cookie

immutable CSRFProtection
end

immutable InvalidCSRFTokenError <: ApplicationError
    conn::Conn
    message
end

const unprotected_methods = [:head, :get, :options]

function check_csrf_token(conn::Conn)
    conn.method in unprotected_methods && return
    if haskey(conn.query_params, :_csrf_token)
        token = conn.query_params[:_csrf_token]
        if Plug.SessionData.has_cookie(token)
            cookie = Plug.SessionData.get_cookie(token)
            if cookie.value == token
                # delete_csrf_token(conn, token)
                Plug.SessionData.hourly_cleaning_expired_cookies(Dates.now())
                return true
            end
        end
    end
    put_status(conn, :forbidden)
    throw(InvalidCSRFTokenError(conn, "Cross Site Request Forgery"))
end

function plug(::Type{Plug.CSRFProtection}; kw...)
    pipe_through(Pipeline(check_csrf_token))
end

function protect_from_forgery(conn::Conn)
    plug(Plug.CSRFProtection)
end

function generate_token()::String
    string("csrf-", Base.Random.uuid1())
end

function get_csrf_token(conn::Conn)::String
    if !haskey(conn.assigns, :csrf_token)
        conn.assigns[:csrf_token] = generate_token()
    end
    conn.assigns[:csrf_token]
end

function delete_csrf_token(conn::Conn, token::String)
    delete!(conn.assigns, :csrf_token)
end

function csrf_token(conn::Conn)
    token = get_csrf_token(conn)
    cookie = Cookie(bukdu_cookie_key, token, Dict{String,String}(
        "expires" => Dates.format(Dates.now() + Dates.Hour(1), Dates.RFC1123Format)
    ))
    Plug.SessionData.set_cookie(cookie)
    put_resp_cookie(conn, cookie)
    token
end
