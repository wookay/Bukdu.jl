# module Bukdu

import HttpCommon: Request, Response


module Server

function info()::String
    "Bukdu (commit $(commit_short())) with Julia $VERSION"
end

function commit_short()::String
    repo = LibGit2.GitRepo(Pkg.dir("Bukdu"))
    string(LibGit2.revparseid(repo, "HEAD"))[1:7]
end

end # module Bukdu.Server

function handler(req::Request, res::Response)
    if method_exists(before, (Request,Response))
        before(req, res)
    end
    verb = getfield(Bukdu, Symbol(lowercase(req.method)))
    local conn::Conn
    try
        conn = Routing.request(RouterRoute.routes, verb, req.resource) do route
            Base.function_name(route.verb) == Base.function_name(verb)
        end
    catch ex
        isa(ex, NoRouteError)
        conn = CONN_NOT_FOUND
    end
    for (key,value) in conn.resp_header
       res.headers[key] = value
    end
    res.headers["Server"] = Server.info()
    res.status = conn.status
    if isa(conn.resp_body, Vector{UInt8}) || isa(conn.resp_body, String)
       res.data = conn.resp_body
    else
       res.data = string(conn.resp_body)
    end
    if method_exists(after, (Request,Response))
        after(req, res)
    end
    res
end


module Farm

import HttpServer
servers = Vector{Tuple{HttpServer.Server,Task}}()

end # module Bukdu.Farm


import HttpServer

function start(port::Int; host=getaddrinfo("localhost"))
    start([port]; host=host)
end

function start(ports::Vector{Int}; host=getaddrinfo("localhost"))
    for port in ports
        server = HttpServer.Server(handler)
        task = @async HttpServer.run(server, host=host, port=port)
        push!(Farm.servers, (server,task))
    end
end

function stop()
    for (server,task) in Farm.servers
        try
            close(server.http)
        catch e
        end
        close(server)
    end
    empty!(Farm.servers)
    nothing
end
