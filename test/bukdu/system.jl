module test_bukdu_system

module NAStuff

using Bukdu
struct NA <: ApplicationController; conn::Conn end
index(c::NA) = nothing
hello(c::NA) = TEST_INTERNAL_ERROR

end # module NAStuff


using Test
using Bukdu
using .Bukdu.System

function index
end

routes() do
    get("/na", NAStuff.NA, index)
    post("/hello", NAStuff.NA, NAStuff.hello)
end

result = Router.call(get, "/na")
@test occursin("Bukdu.System.NotApplicableError", result.got)
@test result.resp.status == 500
@test result.route.action === System.not_applicable

Plug.Loggers.config[:error_stackframes_range] = 1:2
result = Router.call(post, "/hello")
@test result.route.action === System.internal_error

Routing.reset!()

@test Plug.Loggers._regularize_text("가1", 1) == "가"


struct Controller <: ApplicationController
    conn::Conn
end
function index(::Controller)
end

struct VeryLongNamedController <: ApplicationController
    conn::Conn
end
function index(::VeryLongNamedController)
end

routes() do
    get("/just", Controller, index)
    get("/long", VeryLongNamedController, index)
end
Router.call(get, "/just")
Router.call(get, "/long")

Routing.reset!()

end # module test_bukdu_system


module test_bukdu_system_proc_time

using Bukdu

function Bukdu.System.catch_request(route::Bukdu.Route, conn)
    conn.private[:req_time_ns] = time_ns()
end

using Logging: AbstractLogger

struct MyLogger <: AbstractLogger
    stream
end

function Plug.Loggers.info_response(logger::MyLogger, conn::Conn, route::Bukdu.RouteAction)
    io = logger.stream
    proc_time = (time_ns() - conn.private[:req_time_ns]) / 1e9
    print(io, proc_time, ' ')
    Plug.Loggers.default_info_response(io, conn, route)
end

plug(MyLogger, IOContext(Core.stdout, :color => Plug.Loggers.have_color()))


get("/") do conn::Conn
    42
end

Router.call(get, "/")

plug(Plug.Loggers.DefaultLogger)
Routing.reset!()

end # module test_bukdu_system_proc_time
