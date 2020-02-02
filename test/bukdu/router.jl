module test_bukdu_router

using Test
using Bukdu
using HTTP.Messages: header

struct ExController <: ApplicationController
    conn::Conn
end

f1(::ExController) = nothing
f2(::ExController) = "a"
f3(::ExController) = SubString("ab")
f4(::ExController) = 0
f5(::ExController) = 3.14
f6(::ExController) = (1, 2)
f7(::ExController) = (a=1,)

g1(::ExController) = render(JSON, nothing)
g2(::ExController) = render(JSON, "a")
g3(::ExController) = render(JSON, SubString("ab"))
g4(::ExController) = render(JSON, 0)
g5(::ExController) = render(JSON, 3.14)
g6(::ExController) = render(JSON, (1, 2))
g7(::ExController) = render(JSON, (a=1,))

routes() do
    for func in [f1 f2 f3 f4 f5 f6 f7
                 g1 g2 g3 g4 g5 g6 g7]
        get(string("/", nameof(func)), ExController, func)
    end
end

result = Router.call(get, "/f2")
@test result.got == "a"
@test header(result.resp, "Content-Type") == "application/julia; charset=utf-8"
@test result.resp.body == Vector{UInt8}(repr("a"))

for (f, g) in zip([f1 f2 f3 f4 f5 f6 f7],
                  [g1 g2 g3 g4 g5 g6 g7])
    result1 = Router.call(get, string("/", nameof(f)))
    result2 = Router.call(get, string("/", nameof(g)))
    @test result1.got == result2.got
end

Routing.empty!()


# issue 87

using  JSON

struct IndexController <: ApplicationController
    conn::Conn
end

function something(c::IndexController)
    data = c.conn.params[:data]
    return render(JSON,  Dict("status"=>data=="data"))
end

function config_routes()
    routes() do
        post("/something", IndexController, something)
    end
end

function test_something()
    config_routes()
    response = Router.call(post,
                           "/something",
                           ["Content-Type" => "application/json"],
                           JSON.json(Dict("data"=>"data")))
    @test response.got.status == true
end
test_something()

Routing.empty!()

end # module test_bukdu_router
