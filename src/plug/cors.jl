# module Bukdu.Plug

import ....Bukdu
import Base: ismatch

# Cross-Origin Resource Sharing

struct CORS
end

struct CrossOriginResponse
    allow_origin::String            # 5.1 Access-Control-Allow-Origin
    allow_credentials::Bool         # 5.2 Access-Control-Allow-Credentials
    expose_headers::Vector{String}  # 5.3 Access-Control-Expose-Headers
    max_age::Int                    # 5.4 Access-Control-Max-Age
    allow_methods::Vector{Symbol}   # 5.5 Access-Control-Allow-Methods
    allow_headers::Vector{String}   # 5.6 Access-Control-Allow-Headers
end

struct CrossOriginRequest
    origin::String                  # 5.7 Origin
    request_method::Symbol          # 5.8 Access-Control-Request-Method
    request_headers::Vector{String} # 5.9 Access-Control-Request-Headers
end

function ismatch(origins::Vector, cors_req::CrossOriginRequest)::Bool
    ["*"] == origins && return true
    req_origin = cors_req.origin
    for origin in origins
        if isa(origin, Regex)
            ismatch(origin, req_origin) && return true
        else
            origin == req_origin && return true
        end
    end
    false
end

function get_cors_req(conn::Conn)::CrossOriginRequest
    origin = get(conn.req_headers, "Origin", "")
    request_method = get(conn.req_headers, "Access-Control-Request-Method", "")
    request_headers = get(conn.req_headers, "Access-Control-Request-Headers", "")
    CrossOriginRequest(origin, Symbol(lowercase(request_method)), split(request_headers, ", "))
end

function put_cors_res_headers(conn::Conn, cors_resp::CrossOriginResponse)
    conn.resp_headers["Access-Control-Allow-Origin"]          = cors_resp.allow_origin
    if cors_resp.allow_credentials
        conn.resp_headers["Access-Control-Allow-Credentials"] = string(cors_resp.allow_credentials)
    end
    if !isempty(cors_resp.expose_headers)
        conn.resp_headers["Access-Control-Expose-Headers"]    = join(cors_resp.expose_headers, ",")
    end
    conn.resp_headers["Access-Control-Max-Age"]               = string(cors_resp.max_age)
    conn.resp_headers["Access-Control-Allow-Methods"]         = join(uppercase.(string.(cors_resp.allow_methods)), ", ")
    if !isempty(cors_resp.allow_headers)
        conn.resp_headers["Access-Control-Allow-Headers"]     = join(cors_resp.allow_headers, ", ")
    end
    put_status(conn, :no_content) # 204
end

function get_cors_resp(cors_req::CrossOriginRequest, allow_origin, allow_credentials, expose_headers, max_age, allow_methods, allow_headers)
    CrossOriginResponse(cors_req.origin, allow_credentials, expose_headers, max_age, allow_methods, allow_headers)
end

function plug(::Type{Plug.CORS};
              allow_origin = ["*"],
              allow_credentials = false,
              expose_headers = [],
              max_age = 86400,
              allow_methods = [:get, :post, :patch, :put, :delete],
              allow_headers = [],
              only = Vector{Function}(),
              kw...)
    function cross_origin_resource_sharing(conn::Conn)
        :options != conn.method && return false
        cors_req = get_cors_req(conn)
        if !ismatch(allow_origin, cors_req)
            # :method_not_allowed
            return false
        end
        # cors_req.request_method in allow_methods
        # cors_req.request_headers in allow_headers
        cors_resp = get_cors_resp(cors_req, allow_origin, allow_credentials, expose_headers, max_age, allow_methods, allow_headers)
        put_cors_res_headers(conn, cors_resp)
        true
    end
    pipe_through(Pipeline(cross_origin_resource_sharing, only))
end
