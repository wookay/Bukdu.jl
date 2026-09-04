module test_bukdu_server

using Test
using Bukdu
using HTTP: HTTP as HT

@test Bukdu.BUKDU_VERSION >= v"0.5.0-DEV"

routes() do
    post("/") do conn::Conn
        render(Text, "hello")
    end
end

Bukdu.start(8190, host="127.0.0.1")

resp = HT.post("http://127.0.0.1:8190/", body="hello")
# @info HT.header(resp, "Server")
@test HT.header(resp, "Content-Type") == "text/plain"
@test HT.header(resp, "Content-Length") == "5"
@test String(resp.body) == "hello"

Bukdu.stop()

end # module test_bukdu_server
