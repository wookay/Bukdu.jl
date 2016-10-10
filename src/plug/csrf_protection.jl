# module Bukdu.Plug

import ....Bukdu
import Bukdu: ApplicationError, Conn, Pipeline
import Bukdu: put_status, get_req_cookie, put_resp_cookie
import Bukdu: bukdu_cookie_key, bukdu_secret_key
import Bukdu.RouterScope: pipe_through
import HttpCommon: Cookie
import MbedTLS: CIPHER_AES, encrypt, decrypt

immutable CSRFProtection
end

immutable InvalidCSRFTokenError <: ApplicationError
    conn::Conn
    message::String
end

const unprotected_methods = [:head, :get, :options]

function check_csrf_token(conn::Conn)::Bool # throw InvalidCSRFTokenError
    conn.method in unprotected_methods && return false
    if haskey(conn.query_params, :_csrf_token)
        token = conn.query_params[:_csrf_token]
        cookie = get_req_cookie(conn, bukdu_cookie_key)
        if isa(cookie, Cookie)
            cipher_text = hex2bytes(cookie.value)
            plain = String(decrypt(CIPHER_AES, bukdu_secret_key, cipher_text))
            if token == plain
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

function generate_token()::Tuple{String,String}
    token = string("csrf-", Base.Random.uuid1())
    cipher_text = bytes2hex(encrypt(CIPHER_AES, bukdu_secret_key, token))
    (token, cipher_text)
end

function get_csrf_token(conn::Conn)::Tuple{String,String}
    (token, cipher_text) = generate_token()
end

function csrf_token(conn::Conn)
    (token, cipher_text) = get_csrf_token(conn)
    cookie = Cookie(bukdu_cookie_key, cipher_text, Dict{String,String}(
        "expires" => Dates.format(Dates.now() + Dates.Hour(1), Dates.RFC1123Format)
    ))
    put_resp_cookie(conn, cookie)
    token
end
