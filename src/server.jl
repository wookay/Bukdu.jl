# module Bukdu

include("server/handler.jl")


module Farm

import HttpServer
servers = Dict{Type,Vector{Tuple{HttpServer.Server,Task}}}()

end # module Bukdu.Farm

import HttpServer
import HttpCommon: Request, Response

"""
    Bukdu.start(port::Int; host=getaddrinfo("localhost"))

Start Bukdu server with port.

```jula
julia> Bukdu.start(8080)
Listening on 127.0.0.1:8080...
```
"""
function start(port::Int, host=getaddrinfo("localhost"); kw...)
    Bukdu.start([port], host; kw...)
end

function start{AE<:ApplicationEndpoint}(::Type{AE}, port::Int, host=getaddrinfo("localhost"); kw...)
    Bukdu.start(AE, [port], host; kw...)
end

"""
    Bukdu.start(ports::Vector{Int}; host=getaddrinfo("localhost"))

Start Bukdu server with multiple ports.

```jula
julia> Bukdu.start([8080, 8081])
Listening on 127.0.0.1:8080...
```
"""
function start(ports::Vector{Int}, host=getaddrinfo("localhost"); kw...)
    Bukdu.start(Endpoint, ports, host; kw...)
end

function start{AE<:ApplicationEndpoint}(::Type{AE}, ports::Vector{Int}, host=getaddrinfo("localhost"); kw...)
    if AE==Endpoint && !haskey(Routing.runtime, AE)
        Endpoint() do
            plug(Router)
        end
    end

    handler = (req::Request, res::Response) -> Server.handler(AE,req,res)
    for port in ports
        server = HttpServer.Server(handler)
        server.http.events["listen"] = (port) -> Logger.info("Listening on $port..."; LF=!isdefined(:Juno))
        task = @async begin
            HttpServer.run(server, host=host, port=port; kw...)
        end
        if :queued == task.state
            if !haskey(Farm.servers, AE)
                Farm.servers[AE] = Vector{Tuple{HttpServer.Server,Task}}()
            end
            push!(Farm.servers[AE], (server,task))
        end
    end
end

"""
    Bukdu.stop()

Stop the Bukdu server.
"""
function stop()
    Bukdu.stop(Endpoint)
end

function stop{AE<:ApplicationEndpoint}(::Type{AE})
    stopped = 0
    for (server,task) in Farm.servers[AE]
        try
            if Base.StatusActive==server.http.sock.status
                stopped += 1
                close(server)
            end
        catch e
        end
    end
    if stopped >= 1
        Logger.info("Stopped.")
        empty!(Farm.servers[AE])
        delete!(Farm.servers, AE)
        delete!(Routing.runtime, AE)
    end
    nothing
end
