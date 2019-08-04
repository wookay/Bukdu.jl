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

function Plug.Loggers.info_response(logger::MyLogger, req, route::NamedTuple{(:controller, :action)})
    io = logger.stream
    Base.printstyled(io, "MYLOG ", color=:yellow)
    Plug.Loggers.default_info_response(io, req, route)
    Base.flush(io)
end

plug(MyLogger, IOContext(Core.stdout, :color => Plug.Loggers.have_color()))

Bukdu.start(8191)
@test_throws HTTP.ExceptionRequest.StatusError HTTP.get("http://localhost:8191/")
Bukdu.stop()


access_log_path = normpath(@__DIR__, "access.log")
plug(MyLogger, open(access_log_path, "a"))

Bukdu.start(8191)
@test_throws HTTP.ExceptionRequest.StatusError HTTP.get("http://localhost:8191/")
Bukdu.stop()

@test read(access_log_path, String) == """
MYLOG Bukdu Listening on 127.0.0.1:8191
MYLOG INFO: GET     MissingController   not_found       404 /
MYLOG Stopped.
"""
rm(access_log_path)

end # module test_bukdu_plugs_loggers
