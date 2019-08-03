using Test
using Bukdu # Plug plug
using Logging: AbstractLogger
using HTTP

Bukdu.start(8191)
@test_throws HTTP.ExceptionRequest.StatusError HTTP.get("http://localhost:8191/") 
Bukdu.stop()

struct MyLogger <: AbstractLogger
    stream
end

function Plug.Logger.println(::MyLogger, exs...)
    Base.println(exs...)
end

plug(MyLogger, Core.stdout)

Bukdu.start(8191)
@test_throws HTTP.ExceptionRequest.StatusError HTTP.get("http://localhost:8191/") 
Bukdu.stop()
