# module Bukdu

include("status.jl")

import HttpCommon: Cookie

const bukdu_cookie_key = "_bukdu_cookie_key"
const bukdu_secret_key = rand(UInt8, 32)

immutable Pipeline
    block::Function
    only::Vector{Function}
    Pipeline(block::Function) = new(block, Vector{Function}())
    Pipeline(block::Function, only::Vector{Function}) = new(block, only)
end

type Conn
    ## Request fields
    host::String
    method::Symbol
    path::String
    req_headers::Assoc
    scheme::Symbol

    ## Fetchable fields
    req_cookies::Vector{Cookie}
    query_params::Assoc
    params::Assoc

    ## Response fields
    resp_body::Any
    resp_charset::String
    resp_cookies::Vector{Cookie}
    resp_headers::Dict{String,String}
    status::Int    # 418 :im_a_teapot
    before_send::Function

    ## Connection fields
    assigns::Assoc
    halted::Bool
    state::Symbol  # :unset, :set, :file, :chunked, :sent

    ## Private fields
    private::Assoc

    function Conn()
        Conn(:im_a_teapot, Dict{String,String}(), nothing)
    end

    function Conn(status::Symbol, resp_headers::Dict{String,String}, resp_body::Any)
        Conn(statuses[status], resp_headers, resp_body)
    end

    function Conn(code::Int, resp_headers::Dict{String,String}, resp_body::Any)
        Conn(code, resp_headers, resp_body, Assoc(), Assoc(), Assoc(), Assoc())
    end

    function Conn(status::Symbol, resp_headers::Dict{String,String}, resp_body::Any, params::Assoc, query_params::Assoc, private::Assoc, assigns::Assoc)
        Conn(statuses[status], resp_headers, resp_body, params, query_params, private, assigns)
    end

    function Conn(code::Int, resp_headers::Dict{String,String}, resp_body::Any, params::Assoc, query_params::Assoc, private::Assoc, assigns::Assoc)
        new(
            "", :get, "", Assoc(), :http,   # host, method, path, req_headers, scheme,
            Vector{Cookie}(), query_params, params, # req_cookies, query_params, params,
            resp_body, "utf-8", Vector{Cookie}(), resp_headers, code, identity, # resp_body, resp_charset, resp_cookies, resp_headers, status, before_send,
            assigns, false, :unset,                      # assigns, halted, state,
            private                                      # private
        )
    end
end

immutable MissingConnError <: ApplicationError
    conn::Conn
    message::String
end


## Request fields - host, method, path, req_headers, scheme

function get_req_header(conn::Conn, key::String)
    k = Symbol(key)
    if haskey(conn.req_headers, k)
        conn.req_headers[k]
    else
        ""
    end
end

function put_req_header(conn::Conn, key::String, value::String)
    k = Symbol(key)
    conn.req_headers[k] = value
end


## Fetchable fields - req_cookies, query_params, params

function get_req_cookie(conn::Conn, name::String)::Union{Cookie,Void}
    for cookie in conn.req_cookies
        cookie.name == name && return cookie
    end
    return nothing
end


## Response fields - resp_body, resp_charset, resp_cookies, resp_headers, status, before_send

function put_resp_cookie(conn::Conn, cookie::Cookie)
    push!(conn.resp_cookies, cookie)
end

function put_resp_content_type(conn::Conn, content_type::String)
    conn.resp_headers["Content-Type"] = content_type
end

function put_status(conn::Conn, code::Int)
    conn.status = code
end

function put_status(conn::Conn, status::Symbol)
    put_status(conn, statuses[status])
end

function register_before_send(conn::Conn, callback::Function)
    conn.before_send = callback
end

## Connection fields - assigns, halted, state

function halt(conn::Conn)
    conn.halted = true
end


## Private fields - private
function put_private(conn::Conn, key::Symbol, value)
    conn.private[key] = value
end

function action_name(conn::Conn)::Symbol
    Base.function_name(conn.private[:action])
end

function controller_name(conn::Conn)::Symbol
    Symbol(conn.private[:controller])
end

function router_name(conn::Conn)::Symbol
    Symbol(conn.private[:router])
end

function endpoint_name(conn::Conn)::Symbol
    Symbol(conn.private[:endpoint])
end

function (p::Pipeline)(conn::Conn)
    p.block(conn)
end

function plug(conn::Conn, func::Function, args...)
    func(conn, args...)
end

function parse_cookie_string(s)::Vector{Cookie}
    pairs = map(x->split(x, "="), split(s, "; "))
    map(pairs) do pair
        (name, value) = pair
        Cookie(name, value, Dict{String,String}())
    end
end
