# module Bukdu

using .Deps.HTTP
using .HTTP.Sockets

function handle_request(req::HTTP.Request)::NamedTuple{(:got, :resp, :route)}
    body_params = Plug.ContentParsers.fetch_body_params(req)
    query_params = fetch_query_params(req)
    prev_method = req.method
    route = Routing.handle_conn(req, prev_method)
    path_params = parsed_path_params(route)
    params = merge(body_params, query_params, path_params)
    halted = false
    conn = Conn(req, req.method, Assoc.((body_params, query_params, path_params, params))..., halted)
    for (name, pipefunc) in bukdu_env[:prequisite_plugs]
        pipefunc(conn)
        conn.halted && break
    end
    if prev_method != conn.method
        route = Routing.handle_conn(conn.request, conn.method)
    end
    for pipefunc in route.pipelines
        pipefunc(conn)
        conn.halted && break
    end
    request_handler(route, conn)
end

"""
    Bukdu.start(port::Integer; host::Union{String,Sockets.IPAddr}="localhost", kwargs...)

start the Bukdu server.
"""
function start(port::Integer; host::Union{String,Sockets.IPAddr}="localhost", kwargs...)
    ipaddr = host isa Sockets.IPAddr ? host : Sockets.getaddrinfo(host)
    inetaddr = Sockets.InetAddr(ipaddr, port)
    server = Sockets.listen(inetaddr)
    bukdu_env[:server] = server
    task = @async HTTP.serve(ipaddr, port; server=server, verbose=false, kwargs...) do req
        if bukdu_env[:server] === nothing
            req.response.status = 503
            Plug.Loggers.print_message("503 Error", req)
            throw(ErrorException("503"))
            req.response
        else
            handle_request(req).resp
        end
    end
    print_listening_on(inetaddr)
    task
end

"""
    Bukdu.stop()

stop the Bukdu server.
"""
function stop()
    server = bukdu_env[:server]
    if server !== nothing
        close(server)
        bukdu_env[:server] = nothing
        Plug.Loggers.print_message("Bukdu has stopped.")
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
    Plug.Loggers.print_message("Bukdu Listening on ", StyledInetAddr(addr))
end

# module Bukdu
