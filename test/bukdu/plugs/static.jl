module test_bukdu_plugs_static

using Test
using Bukdu

routes(:a) do
    plug(Plug.Static, at="/hello", from=normpath(@__DIR__, "."))
end
result = Router.call(get, "/hello/static.jl")
@test startswith(String(result.resp.body), "module test_bukdu_plugs_static")
Routing.reset!()

routes(:b) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."))
end
result = Router.call(get, "/static.jl")
@test startswith(String(result.resp.body), "module test_bukdu_plugs_static")
Routing.reset!()

routes(:c) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."), only=["static.jl"])
end
result = Router.call(get, "/static.jl")
@test startswith(String(result.resp.body), "module test_bukdu_plugs_static")
@test Router.call(get, "/csrf_protection.jl").resp.status == 404
Routing.reset!()

routes(:d) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end
@test Router.call(get, "/a.html").resp.status == 200
@test Router.call(get, "/b.wasm").resp.status == 200
Routing.reset!()

routes(:e) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end
buf1 = IOBuffer()
CLI.routes(buf1)
routes(:e) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end
buf2 = IOBuffer()
CLI.routes(buf2)
@test take!(buf1) == take!(buf2)
Routing.reset!()

end # module test_bukdu_plugs_static
