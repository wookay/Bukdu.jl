# module Bukdu

module Server

import HttpCommon: Request, Response, Cookie, Headers
import HttpServer: setcookie!
import ....Bukdu
import Bukdu: Routing
import Bukdu: ApplicationEndpoint, ApplicationError, Endpoint, Router, Conn
import Bukdu: before, after, post, plug
import Bukdu: parse_cookie_string
import Bukdu: conn_error, conn_not_found, conn_application_error, conn_internal_server_error
import Bukdu: NoRouteError, HTTP_VERBS, put_status
import Bukdu: Logger

include("content_encoding.jl")
include("form_data.jl")

const commit_short = string(LibGit2.revparseid(LibGit2.GitRepo(Pkg.dir("Bukdu")), "HEAD"))[1:7]
const info = "Bukdu (commit $commit_short) with Julia $VERSION"

function handler{AE<:ApplicationEndpoint}(::Type{AE}, port::Int, req::Request, res::Response)::Response
    if AE==Endpoint && !haskey(Routing.endpoint_routes, AE)
        Endpoint() do
            plug(Router)
        end
    end
    local conn = Conn()
    conn.port = port
    routes = Routing.endpoint_routes[AE]
    applicable(before, req, res) && before(req, res)
    method = Symbol(lowercase(req.method))
    if method in vcat(HTTP_VERBS, :head)
        verb = :head == method ? get : getfield(Bukdu, method)
        compare = (route) -> Base.function_name(route.verb) == Base.function_name(verb)
    else
        # options, trace, connect
        function special_method
        end
        verb = special_method
        compare = (route) -> true
        put_status(conn, :method_not_allowed)
    end
    try
        path = req.resource
        headers = Assoc(req.headers)
        if haskey(headers, :Cookie)
            cookies = parse_cookie_string(headers[:Cookie])
        else
            cookies = Vector{Cookie}()
        end
        req_data = req_data_by_content_encoding(req)::Vector{UInt8}
        param_data = :post==method ? form_data_for_post(req.headers, req_data) : Assoc()
        conn = Routing.route_request(compare, conn, Nullable{Type{AE}}(AE), routes, method, path, headers, cookies, param_data)
    catch ex
        stackframes = stacktrace(catch_backtrace())
        conn = conn_error(method, req.resource, ex, stackframes)
    end
    for (key, value) in conn.resp_headers
        res.headers[key] = value
    end
    res.headers["Server"] = Server.info
    res.status = conn.status
    if !isempty(conn.resp_cookies)
        for cookie in conn.resp_cookies
            setcookie!(res, cookie)
        end
    end
    if method in HTTP_VERBS
        if isa(conn.resp_body, Vector{UInt8}) || isa(conn.resp_body, String)
            res_data = Vector{UInt8}(conn.resp_body)
        else
            res_data = Vector{UInt8}(string(conn.resp_body))
        end
        res_data_by_accept_encoding!(res, req.headers, res_data)
    else
        res.data = Vector{UInt8}()
    end
    applicable(after, req, res) && after(req, res)
    res
end

end # module Bukdu.Server
