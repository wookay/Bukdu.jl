module test_bukdu_plugs_loggers

using Test
using Bukdu # Plug plug
using Logging: AbstractLogger
using HTTP

struct MyLogger <: AbstractLogger
    stream
end

function Plug.Loggers.print_message(logger::MyLogger, args...; kwargs...)
    io = logger.stream
    Base.printstyled(io, "MYLOG ", color=:yellow)
    Base.println(io, args...; kwargs...)
    Base.flush(io)
end

function Plug.Loggers.info_response(logger::MyLogger, conn::Conn, route::Bukdu.RouteAction)
    io = logger.stream
    Base.printstyled(io, "MYLOG ", color=:yellow)
    print(io, something(conn.remote_ip, ""), ' ')
    Plug.Loggers.default_info_response(io, conn, route)
    Base.flush(io)
end

plug(MyLogger, IOContext(Core.stdout, :color => Plug.Loggers.have_color()))
Bukdu.start(8192, enable_remote_ip=true)
@test_throws HTTP.StatusError HTTP.get("http://127.0.0.1:8192/")
Bukdu.stop()

access_log_path = normpath(@__DIR__, "access.log")
plug(MyLogger, open(access_log_path, "w"))
Bukdu.start(8193, enable_remote_ip=true)
@test_throws HTTP.StatusError HTTP.get("http://127.0.0.1:8193/")
Bukdu.stop()
@test read(access_log_path, String) == """
MYLOG Bukdu Listening on 127.0.0.1:8193
MYLOG 127.0.0.1 INFO: GET     MissingController   not_found       404 /
MYLOG Bukdu has stopped.
"""
try Base.rm(access_log_path) catch end

plug(Plug.Loggers.DefaultLogger)

# Sockets: fix return value of getpeername/getsockname (Julia PR #34986)
Bukdu.start(8193, enable_remote_ip=VERSION >= v"1.5.0-DEV.404")
Bukdu.stop()

end # module test_bukdu_plugs_loggers
