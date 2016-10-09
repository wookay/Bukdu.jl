# module Bukdu

module Server

import HttpCommon: Request, Response, Cookie, parsequerystring
import HttpServer: setcookie!
import URIParser: unescape_form
import ....Bukdu
import Bukdu: Routing
import Bukdu: ApplicationEndpoint, ApplicationError, Endpoint, Router, Conn
import Bukdu: before, after, post, plug
import Bukdu: parse_cookie_string
import Bukdu: conn_not_found, conn_application_error
import Bukdu: Logger

include("form_data.jl")

const commit_short = string(LibGit2.revparseid(LibGit2.GitRepo(Pkg.dir("Bukdu")), "HEAD"))[1:7]
const info = "Bukdu (commit $commit_short with Julia $VERSION"

function handler{AE<:ApplicationEndpoint}(::Type{AE}, req::Request, res::Response)
    if AE==Endpoint && !haskey(Routing.endpoint_routes, AE)
        Endpoint() do
            plug(Router)
        end
    end
    routes = Routing.endpoint_routes[AE]
    if method_exists(before, (Request,Response))
        before(req, res)
    end
    method = Symbol(lowercase(req.method))
    verb = :head == method ? get : getfield(Bukdu, method)
    local conn::Conn
    try
        param_data = post==verb ? post_form_data(req) : Assoc()
        headers = Assoc(req.headers)
        if haskey(headers, :Cookie)
            cookies = parse_cookie_string(headers[:Cookie])
        else
            cookies = Vector{Cookie}()
        end
        conn = Routing.request(Nullable{Type{AE}}(AE), routes, method, req.resource, headers, cookies, param_data) do route
            Base.function_name(route.verb) == Base.function_name(verb)
        end
    catch ex
        stackframes = stacktrace(catch_backtrace())
        if isa(ex, ApplicationError)
            conn = conn_application_error(method, req.resource, ex, stackframes)
        else
            if !isa(ex, Bukdu.NoRouteError)
                Logger.error() do
                    Routing.error_route(method, req.resource, ex, stackframes)
                end
            end
            conn = conn_not_found(method, req.resource, ex, stackframes)
        end
    end
    for (key,value) in conn.resp_headers
        res.headers[key] = value
    end
    res.headers["Server"] = Server.info
    res.status = conn.status
    if !isempty(conn.resp_cookies)
        for cookie in conn.resp_cookies
            setcookie!(res, cookie)
        end
    end
    if :head == method
        res.data = UInt8[]
    else
        if isa(conn.resp_body, Vector{UInt8}) || isa(conn.resp_body, String)
            res.data = conn.resp_body
        else
            res.data = string(conn.resp_body)
        end
    end
    if method_exists(after, (Request,Response))
        after(req, res)
    end
    res
end

end # module Bukdu.Server
