import HttpCommon: Request, Response

function handler(req::Request, res::Response)
    verb = getfield(Bukdu, Symbol(lowercase(req.method)))
    conn = Routing.request(req.resource) do route
        Base.function_name(route.verb) == Base.function_name(verb)
    end
    for (key,value) in conn.resp_header
       if "content-type" == key
           res.headers["Content-Type"] = value
       end
    end
    res.status = conn.status
    res.data = conn.resp_body
    res
end


module Farm
import HttpServer: Server
servers = Vector{Server}()
end # module Farm

import HttpServer: Server, run

function start(port::Int; host=getaddrinfo("localhost"))
    start([port]; host=host)
end

function start(ports::Vector{Int}; host=getaddrinfo("localhost"))
    for port in ports
        server = Server(handler)
        push!(Farm.servers, server)
        @async run(server, host=host, port=port)
    end
end

function stop()
    for server in Farm.servers
        try
            close(server.http)
        catch e
        end
        close(server)
    end
    empty!(Farm.servers)
end
