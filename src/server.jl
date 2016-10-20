# module Bukdu

include("server/error.jl")
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
function start(port::Int, host=getaddrinfo("localhost"); kw...)::Void
    Bukdu.start([port], host; kw...)
end

function start{AE<:ApplicationEndpoint}(::Type{AE}, port::Int, host=getaddrinfo("localhost"); kw...)::Void
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
function start(ports::Vector{Int}, host=getaddrinfo("localhost"); kw...)::Void
    Bukdu.start(Endpoint, ports, host; kw...)
end

function start{AE<:ApplicationEndpoint}(::Type{AE}, ports::Vector{Int}, host=getaddrinfo("localhost"); kw...)::Void
    for port in ports
        start_server(AE, port, host; kw...)
    end
    nothing
end

function start(any_port::Symbol, host=getaddrinfo("localhost"); kw...)::Int
    start(Endpoint, any_port, host; kw...)
end

function start{AE<:ApplicationEndpoint}(::Type{AE}, any_port::Symbol, host=getaddrinfo("localhost"); kw...)::Int
    if :any==any_port
        start_server(AE, 9100, host; any_port=true, kw...)
    else
        -1
    end
end

if isdefined(Base, :trylisten)
    import Base: trylisten
else
    # from julia/base/stream.jl
    function trylisten(sock::Base.LibuvServer; backlog::Integer=Base.BACKLOG_DEFAULT)
        Base.check_open(sock)
        err = ccall(:uv_listen, Cint, (Ptr{Void}, Cint, Ptr{Void}),
                    sock, backlog, Base.uv_jl_connectioncb::Ptr{Void})
        sock.status = Base.StatusActive
        return err
    end
end

function start_server{AE<:ApplicationEndpoint}(::Type{AE}, port::Int, host=getaddrinfo("localhost"); any_port=false, kw...)::Int
    handler = (req::Request, res::Response) -> Server.handler(AE, req, res)
    server = HttpServer.Server(handler)
    function listening(addr)
        addr_port = Logger.with_color(:bold, addr)
        Logger.info("Listening on $addr_port..."; LF=!isdefined(:Juno))
    end
    server.http.events["listen"] = listening
    tc = Condition()
    task = @async begin
        if any_port
            while true
                addr = Base.InetAddr(host, port)
                sock = Base.TCPServer()
                if bind(sock, addr) && trylisten(sock) == 0
                    close(sock)
                    port = Int(addr.port)
                    notify(tc)
                    HttpServer.run(server, host=host, port=port; kw...)
                    break
                else
                    close(sock)
                    port = Int(addr.port) + 1
                end
            end
        else
            HttpServer.run(server, host=host, port=port; kw...)
        end
    end
    any_port && wait(tc)
    if task.state in [:queued, :runnable]
        if !haskey(Farm.servers, AE)
            Farm.servers[AE] = Vector{Tuple{HttpServer.Server,Task}}()
        end
        push!(Farm.servers[AE], (server, task))
    end
    port
end


"""
    Bukdu.stop()

Stop the Bukdu server.
"""
function stop()::Void
    Bukdu.stop(Endpoint)
end

function stop{AE<:ApplicationEndpoint}(::Type{AE})::Void
    if haskey(Farm.servers, AE)
        stopped = 0
        for (server, task) in Farm.servers[AE]
            try
                if Base.StatusActive == server.http.sock.status
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
        end
    end
    nothing
end

function reset()
    for x in [Routing.routes,
              Routing.router_routes,
              Routing.endpoint_routes,
              Routing.endpoint_contexts,
              RouterScope.stack,
              RouterScope.pipes,
              ViewFilter.filters]
        empty!(x)
    end
    Logger.have_color(Base.have_color)
end
