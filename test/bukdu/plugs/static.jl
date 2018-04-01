using Test
using Bukdu

routes() do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "."))
end

result = Router.call(get, "/static.jl")
@test startswith(String(result.body), "using Test")

Routing.empty!()
