importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

Endpoint() do
    plug(Plug.Static, at= "/", from= "../examples/public")
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

conn = (Endpoint)("/js/not_found")
@test 404 == conn.status
@test "not found" == conn.resp_body
