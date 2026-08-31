module test_bukdu_routes

using Test
using Bukdu
using HTTP: HTTP as HT

struct VerbController <: ApplicationController
    conn::Conn
end

function index(c::VerbController)
    req = c.conn.request
    (; method, target) = req
    (; method, target)
end

routes() do
    get("/", VerbController, index)
    post("/create", VerbController, index)
    delete("/", VerbController, index)
    patch("/", VerbController, index)
    put("/", VerbController, index)
    options("/", VerbController, index)
end

router = Bukdu.bukdu_router[]
@test router(HT.Request("GET", "/"))        == (method = "GET", target = "/")
@test router(HT.Request("POST", "/create")) == (method = "POST", target = "/create")
@test router(HT.Request("DELETE", "/"))     == (method = "DELETE", target = "/")
@test router(HT.Request("PATCH", "/"))      == (method = "PATCH", target = "/")
@test router(HT.Request("PUT", "/"))        == (method = "PUT", target = "/")
@test router(HT.Request("OPTIONS", "/"))    == (method = "OPTIONS", target = "/")

resp = router(HT.Request("HEAD", "/"))
@test resp.status == 405

end # module test_bukdu_routes
