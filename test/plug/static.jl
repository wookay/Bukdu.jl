module test_plug_static

importall Bukdu
import Bukdu: NoRouteError
import Base.Test: @test, @test_throws

struct WelcomeController <: ApplicationController
end

index(::WelcomeController) = redirect_to("/vuejs-index.html")

Router() do
    get("/", WelcomeController, index)
end

loaded = []
Endpoint() do
    push!(loaded, 1)
    plug(Plug.Static, at= "/", from= normpath("../examples/public"))
    plug(Plug.Logger, level=:error)
    plug(Router)
end

conn = (Endpoint)("/")
@test 302 == conn.status
@test "/vuejs-index.html" == conn.resp_headers["Location"]
@test nothing == conn.resp_body

conn = (Endpoint)("/vuejs-index.html")
@test 200 == conn.status

conn = (Endpoint)("/js/vue.min.js")
@test 200 == conn.status
@test "application/javascript" == conn.resp_headers["Content-Type"]
@test 76807 == sizeof(conn.resp_body)

@test_throws NoRouteError (Endpoint)("/js/not_found")

@test [1] == loaded

reload(Endpoint)

@test [1, 1] == loaded


# issue #19

Endpoint() do
    plug(Plug.Logger, level=:error)
    plug(Plug.Static, at= "/", from= normpath("../examples/public"), only=["css"])
    plug(Plug.Static, at= "/data", from= normpath("../examples/public", "js"))
    plug(Router)
end

reload(Endpoint)

@test 302 == (Router)(get, "/").status
@test_throws NoRouteError (Router)(get, "/vuejs-index.html")
@test_throws NoRouteError (Router)(get, "/js/vue.min.js")
@test_throws NoRouteError (Router)(get, "/css/style.css")
@test_throws NoRouteError (Router)(get, "/data/vue.min.js")

@test 302 == (Endpoint)("/").status
@test_throws NoRouteError (Endpoint)("/vuejs-index.html")
@test_throws NoRouteError (Endpoint)("/js/vue.min.js")
@test 200 == (Endpoint)("/css/style.css").status
@test 200 == (Endpoint)("/data/vue.min.js").status
@test 200 == (Endpoint)("//data/vue.min.js").status

end # module test_plug_static
