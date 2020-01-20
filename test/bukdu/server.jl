module test_bukdu_server

using Test
using Bukdu
using HTTP
using JSON

Bukdu.start(8190)
sleep(0)
Bukdu.stop()

routes() do
    post("/") do conn::Conn
        render(JSON, conn.params.k + 1)
    end
    plug(Plug.Parsers, [:json])
end

Bukdu.start(8190, host="127.0.0.1")
r = HTTP.post("http://127.0.0.1:8190/", ["Content-Type"=>"application/json"]; body=JSON.json((k=2,)))
sleep(0)
@test HTTP.header(r, "Server") == Bukdu.server_info
@test HTTP.header(r, "Content-Type") == "application/json; charset=utf-8"
@test HTTP.header(r, "Content-Length") == "1"
@test r.body == Vector{UInt8}("3")

Plug.Loggers.config[:error_stackframes_range] = 1:2
@test_throws HTTP.ExceptionRequest.StatusError HTTP.post("http://127.0.0.1:8190/"; body=JSON.json((k=3,)))
@test_throws HTTP.ExceptionRequest.StatusError HTTP.post("http://127.0.0.1:8190/", ["Content-Type"=>"application/json"]; body=JSON.json(3))

Bukdu.stop()

Routing.empty!()

version_line = first(filter(line -> startswith(line, "version"), readlines(normpath(pathof(Bukdu), "..", "..", "Project.toml"))))
@test occursin(string(Bukdu.BUKDU_VERSION), version_line)

end # module test_bukdu_server
