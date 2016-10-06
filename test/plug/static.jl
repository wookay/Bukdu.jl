importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

loaded = []
Endpoint() do
    push!(loaded, 1)
    plug(Plug.Static, at= "/", from= "../examples/public")
    plug(Plug.Logger, level=:error)
    plug(Router)
end


using Base.Test
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

@test_throws Bukdu.NoRouteError (Endpoint)("/js/not_found")

@test [1] == loaded

reload(Endpoint)

@test [1, 1] == loaded
