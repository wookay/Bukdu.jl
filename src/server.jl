# module Bukdu

import HttpCommon: Request, Response

function handler(req::Request, res::Response)
    if method_exists(before, (Request,Response))
        before(req, res)
    end
    verb = getfield(Bukdu, Symbol(lowercase(req.method)))
    conn = Routing.request(req.resource) do route
        Base.function_name(route.verb) == Base.function_name(verb)
    end
    for (key,value) in conn.resp_header
       res.headers[key] = value
    end
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

import HttpServer: Server
servers = Vector{Tuple{Server,Task}}()

end # module Bukdu.Farm


import HttpServer: Server, run

function start(port::Int; host=getaddrinfo("localhost"))
    start([port]; host=host)
end

function start(ports::Vector{Int}; host=getaddrinfo("localhost"))
    for port in ports
        server = Server(handler)
        task = @async run(server, host=host, port=port)
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
end
