module test_bukdu_plugs_static

using Test
using Bukdu

routes(:a) do
    plug(Plug.Static, at="/hello", from=normpath(@__DIR__, "."))
end
result = Router.call(get, "/hello/static.jl")
@test startswith(String(result.resp.body), "module test_bukdu_plugs_static")
Routing.empty!()

routes(:b) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."))
end
result = Router.call(get, "/static.jl")
@test startswith(String(result.resp.body), "module test_bukdu_plugs_static")
Routing.empty!()

routes(:c) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."), only=["static.jl"])
end
result = Router.call(get, "/static.jl")
@test startswith(String(result.resp.body), "module test_bukdu_plugs_static")
@test Router.call(get, "/csrf_protection.jl").resp.status == 404
Routing.empty!()

routes(:d) do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end
@test Router.call(get, "/a.html").resp.status == 200
@test Router.call(get, "/b.wasm").resp.status == 200
Routing.empty!()

end # module test_bukdu_plugs_static
