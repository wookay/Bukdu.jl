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


post("/") do conn::Conn
    42
end

result = Router.call(post, "/")
@test result.resp.status == 200
@test result.got == 42
@test result.route.C === Bukdu.System.AnonymousController


post("/:year", :year=>Int) do conn::Conn
    conn.params.year
end

result = Router.call(post, "/42")
@test result.resp.status == 200
@test result.got == 42
@test result.route.C === Bukdu.System.AnonymousController


Routing.empty!()

end # module test_bukdu_anonymous
