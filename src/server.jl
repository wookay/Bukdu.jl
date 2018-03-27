# module Bukdu

# HTTP.Servers HTTP.handle
import Sockets: @ip_str
import .Routing

const env = Dict{Symbol, Any}(
    :server => nothing,
)

function start(port; host=ip"127.0.0.1")
    server = HTTP.Servers.Server(stdout) do req
        route = Routing.handle(req)
        request_handler(route, req)
    end
    env[:server] = server
    @async serve(
                server,
                host,
                port,
                false) # verbose
end

function stop()
    server = env[:server]
    env[:server] = nothing
    server isa HTTP.Servers.Server && put!(server.in, HTTP.Servers.KILL)
    nothing
end

print_listening_on(host, port) = @info "Listening on: $host:$port"



# code from HTTP/src/Servers.jl
import HTTP.Servers: Server, https, RateLimit, ConnectionPool, KILL, nosslconfig, Connection, handle_connection, handle, update!
import MbedTLS: SSLConfig
import Sockets # Sockets.TCPServer
import Sockets: listen, accept, IPAddr
import Dates

function serve(server::Server{T, H}, host, port, verbose) where {T, H}

    tcpserver = Ref{Sockets.TCPServer}()

    @async begin
        while !isassigned(tcpserver)
            sleep(1)
        end
        while true
            val = take!(server.in)
            val == KILL && close(tcpserver[])
        end
    end

    listen(host, port;
           tcpref=tcpserver,
           ssl=(T == https),
           sslconfig=server.options.sslconfig,
           verbose=verbose,
           tcpisvalid=server.options.ratelimit > 0 ? check_rate_limit :
                                                     (tcp; kw...) -> true,
           ratelimits=Dict{IPAddr, RateLimit}(),
           ratelimit=server.options.ratelimit) do request::HTTP.Messages.Request

        handle(server.handler, request)
    end

    return
end

listen(f, host, port; kw...) = listen(f, string(host), Int(port); kw...)
function listen(f::Function,
                host::String="127.0.0.1", port::Int=8081;
                ssl::Bool=false,
                require_ssl_verification::Bool=true,
                sslconfig::SSLConfig=nosslconfig,
                pipeline_limit::Int=ConnectionPool.default_pipeline_limit,
                tcpisvalid::Function=(tcp; kw...)->true,
                tcpref::Ref{Sockets.TCPServer}=Ref{Sockets.TCPServer}(),
                kw...)

    if sslconfig === nosslconfig
        sslconfig = SSLConfig(require_ssl_verification)
    end

    print_listening_on(host, port) ##
    tcpserver = Sockets.listen(Sockets.getaddrinfo(host), port)

    tcpref[] = tcpserver

    try
        while isopen(tcpserver)
            try
                io = accept(tcpserver)
            catch e
                if e isa Base.UVError
                    @warn "$e"
                    break
                else
                    rethrow(e)
                end
            end
            if !tcpisvalid(io; kw...)
                close(io)
                continue
            end
            io = ssl ? getsslcontext(io, sslconfig) : io
            let io = Connection(host, string(port), pipeline_limit, 0, io)
                # @info "Accept:  $io" ##
                @async try
                    handle_connection(f, io; kw...)
                catch e
                    @error "Error:   $io" e stacktrace(catch_backtrace()) ##
                finally
                    close(io)
                    # @info "Closed:  $io" ##
                end
            end
        end
    catch e
        if typeof(e) <: InterruptException
            @warn "Interrupted: listen($host,$port)"
        else
            rethrow(e)
        end
    finally
        close(tcpserver)
    end

    return
end

function check_rate_limit(tcp;
                          ratelimits=nothing,
                          ratelimit::Rational{Int}=Int(10)//Int(1), kw...)
    ip = Sockets.getsockname(tcp)[1]
    rate = Float64(ratelimit.num)
    rl = get!(ratelimits, ip, RateLimit(rate, Dates.now()))
    update!(rl, ratelimit)
    if rl.allowance > rate
        # @warn "throttling $ip" ##
        rl.allowance = rate
    end
    if rl.allowance < 1.0
        @warn "discarding connection from $ip due to rate limiting"
        return false
    else
        rl.allowance -= 1.0
    end
    return true
end

# module Bukdu
