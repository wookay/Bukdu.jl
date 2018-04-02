using Test
using Bukdu

routes() do
    plug(Plug.Static, at="/hello", from=normpath(@__DIR__, "."))
end
result = Router.call(get, "/hello/static.jl")
@test startswith(String(result.got.body), "using Test")
Routing.empty!()

routes() do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."))
end
result = Router.call(get, "/static.jl")
@test startswith(String(result.got.body), "using Test")
Routing.empty!()

routes() do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."), only=["static.jl"])
end
result = Router.call(get, "/static.jl")
@test startswith(String(result.got.body), "using Test")
result = Router.call(get, "/csrf_protection.jl")
@test result.resp.status == 404
Routing.empty!()
