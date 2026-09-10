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

using Base: CoreLogging as Logging
Logging.disable_logging(Bukdu.Logging.Info) # -2000

Bukdu.start(8190, host="127.0.0.1")

try
    resp = HT.post("http://127.0.0.1:8190/", body="hello")
    @test HT.header(resp, "Server") == string("Bukdu/", Bukdu.BUKDU_VERSION)
    @test HT.header(resp, "Content-Type") == "text/plain; charset=utf-8"
    @test HT.header(resp, "Content-Length") == "5"
    @test String(resp.body) == "hello"
catch ex
    if ex isa SystemError
        @test_throws SystemError("read", Int32(54)) rethrow()
    end
end

Bukdu.stop()

Logging.disable_logging(Logging.BelowMinLevel) # -1_000_001

end # module test_bukdu_server
