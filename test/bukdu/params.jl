module test_bukdu_params

using Test
using Bukdu
using HTTP: HTTP as HT
using .HT: URIs

URIs.queryparams
HT.getparams
HT.getparam

struct IndexController <: ApplicationController
    conn::Conn
end

function index(c::IndexController)
    req = c.conn.request
    dict = URIs.queryparams(URIs.URI(req.target))
    dict
end

struct IssueController <: ApplicationController
    conn::Conn
end

function api(c::IssueController)
    req = c.conn.request
    dict = HT.getparams(req)
    dict
end

routes() do
    get("/", IndexController, index)
    get("/api/issue/{issue_id}", IssueController, api)
end

router = Bukdu.bukdu_router[]
@test router(HT.Request("GET", "/?q=1")) == Dict("q" => "1")
@test router(HT.Request("GET", "/api/issue/1")) ==Dict("issue_id" => "1")

@test URIs.URI("/?q=1").query == "q=1"
@test URIs.queryparams("a=b+c&d=e%20f") == Dict("a" => "b c", "d" => "e f")

end # module test_bukdu_params
