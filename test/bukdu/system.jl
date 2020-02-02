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
