# module Bukdu

include("status.jl")

immutable Pipeline
    block::Function
end

type Conn
    ## Request fields
    host::String
    method::Function
    path::String
    req_headers::Dict{String,String}
    scheme::Symbol

    ## Fetchable fields
    req_cookies::Dict{String,String}
    query_params::Assoc
    params::Assoc

    ## Response fields
    resp_body::Any
    resp_charset::String
    resp_cookies::Dict{String,String}
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
            "", get, "", Dict{String,String}(), :http,   # host, method, path, req_headers, scheme,
            Dict{String,String}(), query_params, params, # req_cookies, query_params, params,
            resp_body, "utf-8", Dict{String,String}(), resp_headers, code, identity, # resp_body, resp_charset, resp_cookies, resp_headers, status, before_send,
            assigns, false, :unset,                      # assigns, halted, state,
            private                                      # private
        )
    end
end


## Request fields - host, method, path, req_headers, scheme

function get_req_header(conn::Conn, key::String)
    if haskey(conn.req_headers, key)
        conn.req_headers[key]
    else
        conn.req_headers[key]
    end
end

function put_req_header(conn::Conn, key::String, value::String)
    conn.req_headers[key] = value
end


## Fetchable fields - req_cookies, query_params, params



## Response fields - resp_body, resp_charset, resp_cookies, resp_headers, status, before_send

function put_resp_cookie(conn::Conn, key::String, value::String)
    conn.resp_cookies[key] = value
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
