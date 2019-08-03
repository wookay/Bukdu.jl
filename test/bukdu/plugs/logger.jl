using Test
using Bukdu # Plug plug
using Logging: AbstractLogger
using HTTP

struct MyLogger <: AbstractLogger
    stream
end

function Plug.Logger.println(logger::MyLogger, args...; kwargs...)
    io = logger.stream
    Base.printstyled(io, "MYLOG ", color=:yellow)
    Base.println(io, args...; kwargs...)
end

function Plug.Logger.printstyled(logger::MyLogger, args...; kwargs...)
    io = logger.stream
    Base.printstyled(io, "MYLOG ", color=:yellow)
    Base.printstyled(io, args...; kwargs...)
end

function Plug.Logger.info_response(logger::MyLogger, req, route::NamedTuple{(:controller, :action)})
    io = logger.stream
    Base.printstyled(io, "MYLOG ", color=:yellow)
    Plug.Logger.default_info_response(io, req, route)
end

plug(MyLogger, IOContext(Core.stdout, :color => Plug.Logger.have_color()))

Bukdu.start(8191)
@test_throws HTTP.ExceptionRequest.StatusError HTTP.get("http://localhost:8191/") 
Bukdu.stop()
