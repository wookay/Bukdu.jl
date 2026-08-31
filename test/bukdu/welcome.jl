module test_bukdu_welcome

using Test
using Bukdu
using HTTP: HTTP as HT

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    render(JSON, "Hello World")
end

routes() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

resp = HT.get("http://localhost:8080/")
@test HT.header(resp, "Content-Type") == "application/json"
@test String(resp.body) == repr("Hello World")

Bukdu.stop()

end # module test_bukdu_welcome
