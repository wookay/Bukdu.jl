module test_bukdu_head

using Test
using Bukdu
using HTTP: header

struct IndexController <: ApplicationController
    conn::Conn
end

index(c::IndexController) = render(Text, "ok")

routes() do
    get("/", IndexController, index)
end

result = Router.call(Bukdu.head, "/")
@test result.got === "ok"
@test result.resp.status == 200
@test header(result.resp, "Content-Length") == "0"
@test result.resp.body == Vector{UInt8}()

result = Router.call(get, "/")
@test result.got == "ok"
@test result.resp.status == 200
@test header(result.resp, "Content-Length") == "2"
@test result.resp.body == Vector{UInt8}("ok")

Routing.reset!()

end # module test_bukdu_head
