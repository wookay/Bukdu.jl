importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

track = []
Endpoint() do
    push!(track, :blah)
    plug(Plug.Static, at= "/", from= "../examples/public")
    plug(Plug.Logger, level=:error)
    plug(Router)
end


using Base.Test
conn = (Endpoint)("/index.html")
@test 200 == conn.status
@test "text/html" == conn.resp_header["Content-Type"]
@test startswith(String(conn.resp_body), "<html>")

conn = (Endpoint)("/")
@test 200 == conn.status
@test startswith(String(conn.resp_body), "<html>")

conn = (Endpoint)("/js/vue.min.js")
@test 200 == conn.status
@test "application/javascript" == conn.resp_header["Content-Type"]
@test 76807 == sizeof(conn.resp_body)

@test_throws NoRouteError (Endpoint)("/js/not_found")

@test [:blah] == track
reload(Endpoint)
@test [:blah, :blah] == track
