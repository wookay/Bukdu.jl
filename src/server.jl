# module Bukdu

include("server/error.jl")
include("server/handler.jl")

module Farm

import HttpServer
servers = Vector{Tuple{Type,Int,HttpServer.Server}}()

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

function start{AE<:ApplicationEndpoint}(::Type{AE}, port::Int, host=getaddrinfo("localhost"); kw...)::Void
    Bukdu.start(AE, [port], host; kw...)
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
    function listening(addr)
        use_https = haskey(Dict(kw), :ssl)
        address = Logger.with_color(:bold, string(use_https ? "https" : "http", "://", addr))
        Logger.info("Listening on $address"; LF=!isdefined(:Juno))
    end
    function http_server(port::Int)::HttpServer.Server
        handler = (req::Request, res::Response) -> Server.handler(AE, port, req, res)
        server = HttpServer.Server(handler)
        server.http.events["listen"] = listening
        server
    end
    local server = nothing
    tc = Condition()
    task = @async begin
        if any_port
            while true
                addr = Base.InetAddr(host, port)
                sock = Base.TCPServer()
                if bind(sock, addr) && trylisten(sock) == 0
                    close(sock)
                    port = Int(addr.port)
                    server = http_server(port)
                    notify(tc)
                    HttpServer.run(server, host=host, port=port; kw...)
                    break
                else
                    close(sock)
                    port = Int(addr.port) + 1
                end
            end
        else
            server = http_server(port)
            notify(tc)
            HttpServer.run(server, host=host, port=port; kw...)
        end
    end
    wait(tc)
    if task.state in [:queued, :runnable]
        push!(Farm.servers, (AE, port, server))
    end
    port
end

"""
    Bukdu.stop()

Stop the Bukdu server.
"""
function stop()::Void
    stop_servers([port for (E,port,server) in Farm.servers])
end

function stop(port::Int)::Void
    stop_servers([port])
end

function stop{AE<:ApplicationEndpoint}(::Type{AE})::Void
    stop_servers([port for (E,port,server) in Farm.servers if AE==E])
end

function stop_servers(ports::Vector{Int})::Void
    inds = []
    stopped = []
    for (idx, (E,port,server)) in enumerate(Farm.servers)
        try
            if port in ports && Base.StatusActive == server.http.sock.status
                push!(inds, idx)
                push!(stopped, port)
                close(server)
            end
        catch ex
        end
    end
    if !isempty(inds)
        deleteat!(Farm.servers, inds)
        Logger.info(string("Stopped ", "(", join(stopped, ", "), ")"))
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
              ViewFilter.filters,
              Octo.Schema.relations]
        empty!(x)
    end
    Logger.have_color(Base.have_color)
end
