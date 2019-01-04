# module Bukdu

using Dates
using .Deps.HTTP
using .HTTP.Sockets
using .HTTP.Servers: Server, KILL

const env = Dict{Symbol, Any}(
    :server => nothing,
)

function routing_handle(request::HTTP.Request)
    route = Routing.handle(request)
    result = request_handler(route, request)
    result.resp
end

"""
    Bukdu.start(port::Integer; host::String="localhost")

start the Bukdu server.
"""
function start(port::Integer; host::String="localhost")
    server = Server(routing_handle, stdout)
    env[:server] = server
    addr = Sockets.InetAddr(Sockets.getaddrinfo(host), port)
    @async _serve(server, addr, false) # !verbose
end

"""
    Bukdu.stop()

stop the Bukdu server.
"""
function stop()
    server = env[:server]
    env[:server] = nothing
    if server isa Server
        put!(server.in, KILL)
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



### code from https://github.com/JuliaWeb/HTTP.jl
### Remove some warnings in HTTP.jl

using .HTTP.Servers: SSLConfig, Connection, ConnectionPool, RateLimit
using .HTTP.Servers: https, handle, update!, getsslcontext, handle_connection

# HTTP.jl/src/Servers.jl - check_rate_limit
function _check_rate_limit(tcp;
                          ratelimits=nothing,
                          ratelimit::Rational{Int}=Int(10)//Int(1), kw...)
    ip = Sockets.getsockname(tcp)[1]
    rate = Float64(ratelimit.num)
    rl = get!(ratelimits, ip, RateLimit(rate, Dates.now()))
    update!(rl, ratelimit)
    if rl.allowance > rate
        ## @warn "throttling $ip"
        rl.allowance = rate
    end
    if rl.allowance < 1.0
        ## @warn "discarding connection from $ip due to rate limiting"
        return false
    else
        rl.allowance -= 1.0
    end
    return true
end

# HTTP.jl/src/Servers.jl - serve
function _serve(server::Server{T, H}, host::Sockets.InetAddr, verbose::Bool) where {T, H}

    tcpserver = Ref{Base.IOServer}()

    @async begin
        while !isassigned(tcpserver)
            sleep(1)
        end
        while true
            val = take!(server.in)
            val == KILL && close(tcpserver[])
        end
    end

    _listen(host;
           tcpref=tcpserver,
           ssl=(T == https),
           sslconfig=(T == https) ? server.options.sslconfig : nothing,
           verbose=verbose,
           tcpisvalid=server.options.ratelimit > 0 ? _check_rate_limit :
                                                     (tcp; kw...) -> true,
           ratelimits=Dict{Sockets.IPAddr, RateLimit}(),
           ratelimit=server.options.ratelimit) do request::HTTP.Request

        handle(server.handler, request)
    end

    return
end

# HTTP.jl/src/Servers.jl - listenloop
function _listenloop(f, tcpserver, sslconfig, hostname, hostport, pipeline_limit, require_ssl_verification, tcpisvalid, connectioncounter; kw...)
    try
        id = 0
        while isopen(tcpserver)
            try
                io = accept(tcpserver)
                if !tcpisvalid(io; kw...)
                    @info "Accept-Reject:  $io"
                    close(io)
                    continue
                end
                io = getsslcontext(io, sslconfig)
                let i=id, conn = Connection(hostname, hostport, pipeline_limit, 0, require_ssl_verification, io)
                    @async try
                        ## @info "Accept ($i):  $conn"
                        connectioncounter[] += 1
                        handle_connection(f, conn; kw...)
                    catch e
                        ## @error "Error ($i):  $conn" exception=(e, stacktrace(catch_backtrace()))
                    finally
                        connectioncounter[] -= 1
                        close(conn)
                        ## @info "Closed ($i):  $conn"
                    end
                end
            catch e
                if e isa Base.IOError
                    ## @warn "Base.IOError $e"
                    break
                else
                    rethrow(e)
                end
            end
            id += 1
        end
    catch e
        if e isa InterruptException
            @warn "Interrupted: listen($hostname)"
        else
            rethrow(e)
        end
    finally
        close(tcpserver)
    end

    return
end

# HTTP.jl/src/Servers.jl - listen
function _listen(f::Function,
                host::Sockets.InetAddr;
                ssl::Bool=false,
                require_ssl_verification::Bool=true,
                sslconfig::Union{SSLConfig, Nothing}=nothing,
                pipeline_limit::Int=ConnectionPool.default_pipeline_limit,
                tcpisvalid::Function=(tcp; kw...)->true,
                tcpref::Ref=Ref{Base.IOServer}(),
                reuseaddr::Bool=false,
                connectioncounter::Base.RefValue{Int}=Ref(0),
                kw...)

    if ssl && sslconfig === nothing
        sslconfig = SSLConfig(require_ssl_verification)
    end

    ## @info "Listening on: $host"
    print_listening_on(host) ## Bukdu
    if isassigned(tcpref)
        tcpserver = tcpref[]
    elseif reuseaddr
        tcpserver = Sockets.TCPServer(; delay=false)
        if Sys.islinux() || Sys.isapple()
            rc = ccall(:jl_tcp_reuseport, Int32, (Ptr{Cvoid},), tcpserver.handle)
            Sockets.bind(tcpserver, host.host, host.port; reuseaddr=true)
        else
            @warn "reuseaddr=true may not be supported on this platform: $(Sys.KERNEL)"
            Sockets.bind(tcpserver, host.host, host.port; reuseaddr=true)
        end
        Sockets.listen(tcpserver)
    else
        tcpserver = Sockets.listen(host)
        tcpref[] = tcpserver
    end

    if host isa Sockets.InetAddr # build debugging info
        hostname = string(host.host)
        hostport = string(host.port)
    else
        hostname = string(host)
        hostport = ""
    end
    _listenloop(f, tcpserver, sslconfig, hostname, hostport, pipeline_limit, require_ssl_verification, tcpisvalid, connectioncounter; kw...)
end

# module Bukdu
