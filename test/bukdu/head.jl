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
@test result.got === nothing
@test result.resp.status == 301
@test result.resp.body == Vector{UInt8}()

result = Router.call(get, "/")
@test result.got == "ok"
@test result.resp.status == 200
@test result.resp.body == Vector{UInt8}("ok")

Routing.empty!()

end # module test_bukdu_head
