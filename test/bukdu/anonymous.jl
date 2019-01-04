module test_bukdu_anonymous

using Test # @test
using Bukdu # Conn

get("/") do conn::Conn
    42
end

result = Router.call(get, "/")
@test result.resp.status == 200
@test result.got == 42
@test result.route.C === Bukdu.System.AnonymousController

Routing.empty!()

end # module test_bukdu_anonymous
