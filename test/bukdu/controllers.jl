module test_bukdu_controllers

using Test # @test_throws @test
using Bukdu # routes get ApplicationController Routing redirect_to Router

struct FrontController <: ApplicationController
    conn::Conn
end
index(c::FrontController) = redirect_to(c.conn, "/path")

@test_throws Routing.AbstractControllerError routes(() -> get("/", ApplicationController, index))

routes() do
    get("/", FrontController, index)
end
result = Router.call(get, "/")
@test result.resp.status == 302
@test result.route.action === index

Routing.reset!()

end # module test_bukdu_controllers
