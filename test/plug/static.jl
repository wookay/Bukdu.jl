module test_plug_static

importall Bukdu
import Bukdu: NoRouteError
import Base.Test: @test, @test_throws

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

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

conn = (Endpoint)("/index.html")
@test 200 == conn.status
@test "text/html" == conn.resp_headers["Content-Type"]
@test startswith(String(conn.resp_body), "<!DOCTYPE html>")

conn = (Endpoint)("/")
@test 200 == conn.status
@test startswith(String(conn.resp_body), "<!DOCTYPE html>")

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

@test 200 == (Router)(get, "/").status
@test_throws NoRouteError (Router)(get, "/index.html")
@test_throws NoRouteError (Router)(get, "/js/vue.min.js")
@test_throws NoRouteError (Router)(get, "/css/style.css")
@test_throws NoRouteError (Router)(get, "/data/vue.min.js")

@test 200 == (Endpoint)("/").status
@test_throws NoRouteError (Endpoint)("/index.html")
@test_throws NoRouteError (Endpoint)("/js/vue.min.js")
@test 200 == (Endpoint)("/css/style.css").status
@test 200 == (Endpoint)("/data/vue.min.js").status

end # module test_plug_static
