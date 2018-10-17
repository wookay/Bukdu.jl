# module Bukdu

const env = Dict{Symbol, Any}(
    :server => nothing,
    :check_websocket => false,
    :check_server_sent_events => false,
    :sse_streams => Dict{RawFD,Any}(),
    :websockets => Dict{RawFD,Any}(),
)

function sse_streams()
    streams = Dict{RawFD,Any}()
    dirty = false
    for (key, http) in pairs(env[:sse_streams])
         s = Base.uv_status_string(http.stream.c.io)
         if s == "paused"
             streams[key] = http
         else
             dirty = true
         end
    end
    if dirty
        env[:sse_streams] = streams
    end
    values(streams)
end

function websockets()
    sockets = Dict{RawFD,Any}()
    dirty = false
    for (key, ws) in pairs(env[:websockets])
         s = Base.uv_status_string(ws.io.c.io)
         if s == "active"
             sockets[key] = ws
         else
             dirty = true
         end
    end
    if dirty
        env[:websockets] = sockets
    end
    values(sockets)
end

function _base_routing_handle(http::Deps.HTTP.Stream) # result
    request::Deps.Request = http.message
    request.body = read(http)
    route = Routing.handle(request)
    request_handler(route, request) # result
end

function routing_handle(http::Deps.HTTP.Stream)::Bool # needs_to_close
    result = _base_routing_handle(http)
    startwrite(http)                   #
    write(http, result.resp.body) #
    true
end

function full_routing_handle(http::Deps.HTTP.Stream)::Bool # needs_to_close
    if Deps.HTTP.WebSockets.is_upgrade(http.message)
        Deps.HTTP.WebSockets.upgrade(http) do ws::Deps.HTTP.WebSockets.WebSocket
            fd = Base._fd(ws.io.c.io)
            env[:websockets][fd] = ws
            while !eof(ws)
                data = readavailable(ws)
                write(ws, data)
            end
        end
        true
    else
        result = _base_routing_handle(http)
        if result.got isa EventStream
            fd = Base._fd(http.stream.c.io)
            env[:sse_streams][fd] = http
            needs_to_close = false
        else
            startwrite(http)              #
            write(http, result.resp.body) #
            needs_to_close = true
        end
        needs_to_close
    end
end


using Sockets: @ip_str
function start(port; host=ip"127.0.0.1")
    server = Deps.HTTP.Servers.Server(routing_handle, stdout)
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
    env[:check_websocket] = false
    env[:check_server_sent_events] = false
    env[:sse_streams] = Dict{RawFD,Any}()
    env[:websockets] = Dict{RawFD,Any}()
    server isa Deps.HTTP.Servers.Server && put!(server.in, Deps.HTTP.Servers.KILL)
    nothing
end

print_listening_on(host, port) = @info "Bukdu Listening on: $host:$port"



#########################################################################
#
#  customizing HTTP.jl
#
#  original code from https://github.com/JuliaWeb/HTTP.jl/tree/master/src

using .Deps.HTTP
using .HTTP.Servers.ConnectionPool
using .HTTP.Servers.Streams
using .HTTP.Servers: iswritable, hasheader, setheader, writeheaders
using .HTTP.Servers: Server, RateLimit, Transaction, Stream, KILL, https, nolimit, startread, closeread, closewrite, isioerror, update!
using .HTTP.IOExtras: startwrite
using .ConnectionPool: nosslconfig, Connection
using Sockets # Sockets.TCPServer
using .Sockets: accept, IPAddr

# HTTP.jl - Servers.jl
# doesn't need to be closed when EventStream has set
function _handle_stream(f::Function, http::Stream)::Nothing
    needs_to_close = true
    try
        needs_to_close = f(http) # routing_handle full_routing_handle
    catch e
        if isopen(http) && !iswritable(http)
            @error Symbol(:server_, :_handle_stream) e stacktrace(catch_backtrace())
            http.message.response.status = 500
            startwrite(http)
            write(http, sprint(showerror, e))
        else
            rethrow(e)
        end
    end
    if needs_to_close # SSE
        closeread(http)
        closewrite(http)
    end
    nothing
end

using Dates: now
# HTTP.jl - Servers.jl
function _check_rate_limit(tcp;
                          ratelimits=nothing,
                          ratelimit::Rational{Int}=Int(10)//Int(1), kw...)
    ip = Sockets.getsockname(tcp)[1]
    rate = Float64(ratelimit.num)
    rl = get!(ratelimits, ip, RateLimit(rate, now()))
    update!(rl, ratelimit)
    if rl.allowance > rate
        # @warn Symbol(:server_, :_check_rate_limit) "throttling $ip" ## bukdu
        rl.allowance = rate
    end
    if rl.allowance < 1.0
        @warn Symbol(:server_, :_check_rate_limit) "discarding connection from $ip due to rate limiting"
        return false
    else
        rl.allowance -= 1.0
    end
    return true
end

# HTTP.jl - Servers.jl
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

    f = env[:check_websocket] || env[:check_server_sent_events] ? full_routing_handle : routing_handle ## bukdu
    listen(f, host, port;
           tcpref=tcpserver,
           ssl=(T == https),
           sslconfig=server.options.sslconfig,
           verbose=verbose,
           tcpisvalid=server.options.ratelimit > 0 ? _check_rate_limit :
                                                     (tcp; kw...) -> true,
           ratelimits=Dict{IPAddr, RateLimit}(),
           ratelimit=server.options.ratelimit)

    return
end


# HTTP.jl - Servers.jl
listen(f, host, port; kw...) = listen(f, string(host), Int(port); kw...)
function listen(f::Function,
                host::String="127.0.0.1", port::Int=8081;
                ssl::Bool=false,
                require_ssl_verification::Bool=true,
                sslconfig::Deps.MbedTLS.SSLConfig=nosslconfig,
                pipeline_limit::Int=ConnectionPool.default_pipeline_limit,
                tcpisvalid::Function=(tcp; kw...)->true,
                tcpref::Ref{Sockets.TCPServer}=Ref{Sockets.TCPServer}(),
                kw...)

    if sslconfig === nosslconfig
        sslconfig = Deps.MbedTLS.SSLConfig(require_ssl_verification)
    end

    print_listening_on(host, port) ##
    tcpserver = Sockets.listen(Sockets.getaddrinfo(host), port)

    tcpref[] = tcpserver

    try
        while isopen(tcpserver)
            try
                io = accept(tcpserver)
            catch e
                if e isa Base.IOError
                    @warn Symbol(:server_, :listen) "$e"
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
            let io = Connection(host, string(port), pipeline_limit, 0, require_ssl_verification, io)
                # @info "Accept:  $io" ##
                @async try
                    _handle_connection(f, io; kw...)
                catch e
                    @error Symbol(:server_, :listen) "Error:   $io" e stacktrace(catch_backtrace()) ##
                finally
                    close(io)
                    # @info "Closed:  $io" ##
                end
            end
        end
    catch e
        if typeof(e) <: InterruptException
            @warn Symbol(:server_, :listen) "Interrupted: listen($host,$port)"
        else
            rethrow(e)
        end
    finally
        close(tcpserver)
    end

    return
end


# HTTP.jl - Servers.jl
function _handle_connection(f::Function, c::Connection;
                           reuse_limit::Int=nolimit,
                           readtimeout::Int=0, kw...)

    wait_for_timeout = Ref{Bool}(true)
    if readtimeout > 0
        @async while wait_for_timeout[]
            @show inactiveseconds(c)
            if inactiveseconds(c) > readtimeout
                @warn Symbol(:server_, :_handle_connection) "Timeout: $c"
                writeheaders(c.io, Response(408, ["Connection" => "close"]))
                close(c)
                break
            end
            sleep(8 + rand() * 4)
        end
    end

    try
        count = 0
        while isopen(c)
            io = Transaction(c)
            final = count == reuse_limit
            _handle_transaction(f, io; final_transaction=final,
                                      kw...)
            if count == reuse_limit
                @info "close " count reuse_limit
                close(c)
            end
            count += 1
        end
    finally
        wait_for_timeout[] = false
    end
    return
end


# HTTP.jl - Servers.jl
function _handle_transaction(f::Function, t::Transaction;
                            final_transaction::Bool=false,
                            verbose::Bool=false, kw...)
    request = HTTP.Request()
    http = Streams.Stream(request, t)

    try
        startread(http)
    catch e
        # @show typeof(e)
        # @show fieldnames(e)
        if e isa EOFError && isempty(request.method)
            return
# FIXME https://github.com/JuliaWeb/HTTP.jl/pull/178#pullrequestreview-92547066
#        elseif !isopen(http)
#            @warn "Connection closed"
#            return
        elseif e isa HTTP.ParseError
            # @error Symbol(:server_, :_handle_transaction) e ## bukdu WebSocketError
            status = e.code == :HEADER_SIZE_EXCEEDS_LIMIT  ? 413 : 400
            write(t, Response(status, body = string(e.code)))
            close(t)
            return
        else
            rethrow(e)
        end
    end

    if verbose
        @info http.message
    end

    response = request.response
    #response.status = 200
    if final_transaction || hasheader(request, "Connection", "close")
        setheader(response, "Connection" => "close")
    end

    @async try
        _handle_stream(f, http)
    catch e
        if isioerror(e)
            @warn Symbol(:server_, :_handle_transaction) e
            #   ArgumentError("stream is closed or unusable")
            #   write: broken pipe (EPIPE)
        else
            # @error Symbol(:server_, :_handle_transaction) e stacktrace(catch_backtrace()) ## bukdu WebSocketError
        end
        close(t)
    end
    return
end

# module Bukdu
