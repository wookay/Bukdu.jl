# module Bukdu

include("server/handler.jl")


module Farm

import HttpServer
servers = Vector{Tuple{HttpServer.Server,Task}}()

end # module Bukdu.Farm


import HttpServer

"""
    Bukdu.start(port::Int; host=getaddrinfo("localhost"))

Start Bukdu server with port.

```jula
julia> Bukdu.start(8080)
Listening on 127.0.0.1:8080...
```
"""
function start(port::Int; host=getaddrinfo("localhost"))
    start([port]; host=host)
end

"""
    Bukdu.start(ports::Vector{Int}; host=getaddrinfo("localhost"))

Start Bukdu server with multiple ports.

```jula
julia> Bukdu.start([8080, 8081])
Listening on 127.0.0.1:8080...
```
"""
function start(ports::Vector{Int}; host=getaddrinfo("localhost"))
    for port in ports
        server = HttpServer.Server(Server.handler)
        server.http.events["listen"] = (port) -> Logger.info("Listening on $port..."; LF=!isdefined(:Juno))
        task = @async begin
            HttpServer.run(server, host=host, port=port)
        end
        if :queued == task.state
            push!(Farm.servers, (server,task))
        end
    end
end

"""
    Bukdu.stop()

Stop the Bukdu server.
"""
function stop()
    stopped = 0
    for (server,task) in Farm.servers
        try
            if Base.StatusActive == server.http.sock.status
                stopped += 1
            end
            close(server)
        catch e
        end
    end
    if stopped >= 1
        Logger.info("Stopped.")
        empty!(Farm.servers)
    end
    nothing
end
