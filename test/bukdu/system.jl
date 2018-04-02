module test_bukdu_system

using Test
using Bukdu

module NAStuff
using Bukdu
struct NA <: ApplicationController; conn::Conn end
index(c::NA) = nothing
hello(c::NA) = err

end # module NAStuff

function index
end

routes() do
    get("/na", NAStuff.NA, index)
    post("/hello", NAStuff.NA, NAStuff.hello)
end

result = Router.call(get, "/na")
@test result.route.action === Bukdu.System.not_applicable

result = Router.call(post, "/hello")
@test result.route.action === Bukdu.System.internal_error

Routing.empty!()

end # module test_bukdu_system
