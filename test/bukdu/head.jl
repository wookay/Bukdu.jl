module test_bukdu_head

using Test
using Bukdu

struct IndexController <: ApplicationController
    conn::Conn
end

index(c::IndexController) = render(Text, "ok")

routes() do
    get("/", IndexController, index)
end

result = Router.call(Bukdu.head, "/")
@test result.resp.status == 200
@test result.got == nothing

result = Router.call(get, "/")
@test result.resp.status == 200
@test result.got.body == Vector{UInt8}("ok")

Routing.empty!()

end # module test_bukdu_head
