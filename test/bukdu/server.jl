module test_bukdu_server

using Test
using Bukdu
using HTTP

@test Bukdu.BUKDU_VERSION >= v"0.4.19"

Bukdu.start(8190)
sleep(0)
Bukdu.stop()

routes() do
    post("/") do conn::Conn
        render(JSON, conn.params.k + 1)
    end
    plug(Plug.Parsers, [:json])
end

using JSON
json_encode = JSON.json

Bukdu.start(8190, host="127.0.0.1")
r = HTTP.post("http://127.0.0.1:8190/", ["Content-Type"=>"application/json"]; body=json_encode((k=2,)))
sleep(0)
@test HTTP.header(r, "Server") == Bukdu.server_info
@test HTTP.header(r, "Content-Type") == "application/json; charset=utf-8"
@test HTTP.header(r, "Content-Length") == "1"
@test r.body == Vector{UInt8}("3")

Plug.Loggers.config[:error_stackframes_range] = 1:2
@test_throws HTTP.ExceptionRequest.StatusError HTTP.post("http://127.0.0.1:8190/"; body=json_encode((k=3,)))
@test_throws HTTP.ExceptionRequest.StatusError HTTP.post("http://127.0.0.1:8190/", ["Content-Type"=>"application/json"]; body=json_encode(3))

Bukdu.stop()

Routing.reset!()

end # module test_bukdu_server
