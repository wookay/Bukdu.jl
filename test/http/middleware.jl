module test_http_middleware

using Test
using HTTP: HTTP as HT

struct Middleware <: HT.Middleware
end

abstract type ApplicationController end
struct Conn
    req::HT.Request
end
const bukdu_router = Ref{HT.Router}()

function get(path, ::Type{C}, f) where C <: ApplicationController
    HT.register!(bukdu_router[], "GET", path, (C, f))
end

function (::Middleware)(tup::Tuple)
    (C, f) = tup
    req -> begin
        conn = Conn(req)
        inst = C(conn)
        f(inst)
    end
end

function routes(f)
    middleware = Middleware()
    bukdu_router[] = HT.Router(HT.Handlers.default404, HT.Handlers.default405, middleware)
    f()
end

function render(T, text)
    HT.Response(200, ["Content-Type" => "text/plain"]; body = text)
end


struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(::WelcomeController)
    render(Text, "hello")
end

@test !isassigned(bukdu_router)

routes() do
    get("/", WelcomeController, index)
end

@test isassigned(bukdu_router)

req = HT.Request("GET", "/")
@test isempty(req.context)
resp = bukdu_router[](req)
@test req.context[:route] == "/"
@test String(resp.body.data) == "hello"

end # module test_http_middleware
