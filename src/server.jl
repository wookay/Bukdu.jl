# module Bukdu

using Dates
using .Deps.HTTP
using .HTTP.Sockets

const env = Dict{Symbol, Any}(
    :server => nothing,
)

function routing_handle(request::HTTP.Request)
    route = Routing.handle(request)
    result = request_handler(route, request)
    result.resp
end

"""
    Bukdu.start(port::Integer; host::String="localhost", kwargs...)

start the Bukdu server.
"""
function start(port::Integer; host::String="localhost", kwargs...)
    ipaddr = Sockets.getaddrinfo(host)
    inetaddr = Sockets.InetAddr(ipaddr, port)
    server = Sockets.listen(inetaddr)
    env[:server] = server
    task = @async HTTP.serve(ipaddr, port; server=server, verbose=false, kwargs...) do req
        routing_handle(req)
    end
    print_listening_on(inetaddr)
    task
end

"""
    Bukdu.stop()

stop the Bukdu server.
"""
function stop()
    server = env[:server]
    env[:server] = nothing
    if server !== nothing
        close(server)
        @info "Stopped."
    end
    nothing
end

struct StyledInetAddr{T<:Sockets.IPAddr}
    host::T
    port::UInt16
    StyledInetAddr(addr::Sockets.InetAddr) = new{typeof(addr.host)}(addr.host, addr.port)
end

function Base.show(io::IO, saddr::StyledInetAddr)
    printstyled(io, string(saddr.host, ':', saddr.port), color=:green)
end

function print_listening_on(addr::Sockets.InetAddr)
    @info "Bukdu Listening on" StyledInetAddr(addr)
end

# module Bukdu
