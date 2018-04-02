module test_bukdu_system


module NAStuff

using Bukdu
struct NA <: ApplicationController; conn::Conn end
index(c::NA) = nothing
hello(c::NA) = err

end # module NAStuff


using Test
using Bukdu
import .Bukdu: System

function index
end

routes() do
    get("/na", NAStuff.NA, index)
    post("/hello", NAStuff.NA, NAStuff.hello)
end

result = Router.call(get, "/na")
@test result.route.action === System.not_applicable

result = Router.call(post, "/hello")
@test result.route.action === System.internal_error

Routing.empty!()

@test System._regularize_text("가1", 1) == "가"

end # module test_bukdu_system
