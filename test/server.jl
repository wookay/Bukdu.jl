module test_server

importall Bukdu
import Requests # Requests.get, Requests.head
import Requests: URI, statuscode, text
import HttpCommon: Request, Response
import Base.Test: @test, @test_throws

type WelcomeController <: ApplicationController
end

type ALayout <: ApplicationLayout
end

layout(::ALayout, body) = body
index(::WelcomeController) = render(Text/ALayout, "hello world")
show(::WelcomeController) = pi

Router() do
    get("/", WelcomeController, index)
    get("/pi", WelcomeController, show)
end

Endpoint() do
    plug(Plug.Logger, level=:error)
    plug(Router)
end


req = Request()

req.method = "GET"
req.resource = "/"
res = Bukdu.Server.handler(Endpoint, req, Response())
@test 200 == res.status
@test "hello world" == String(res.data)

req.method = "GET"
req.resource = "/pi"
res = Bukdu.Server.handler(Endpoint, req, Response())
@test 200 == res.status
@test "π = 3.1415926535897..." == String(res.data)

req.method = "POST"
req.resource = "/"
res = Bukdu.Server.handler(Endpoint, req, Response())
@test 404 == res.status

req.method = "GET"
req.resource = "/test"
res = Bukdu.Server.handler(Endpoint, req, Response())
@test 404 == res.status


try

Bukdu.start([8082, 8083])
resp1 = Requests.get(URI("http://localhost:8082/"))
resp2 = Requests.get(URI("http://localhost:8083/"))
@test 200 == statuscode(resp1)
@test 200 == statuscode(resp2)
@test "hello world" == text(resp1)
@test "hello world" == text(resp2)

resp1 = Requests.head(URI("http://localhost:8082/"))
resp2 = Requests.head(URI("http://localhost:8082/err"))
@test 200 == statuscode(resp1)
@test 404 == statuscode(resp2)
@test "" == text(resp1)

req.method = "GET"
req.resource = "/"

(server,task) = first(Bukdu.Farm.servers[Endpoint])
@test :runnable == task.state
@test "hello world" == text(server.http.handle(req, Response()))

sleep(0.1)
Bukdu.stop()

end # try


logs = []

before(::Request, ::Response) = push!(logs, :br)
before(::WelcomeController) = push!(logs, :bc)
after(::WelcomeController) = push!(logs, :ac)
after(::Request, ::Response) = push!(logs, :ar)

conn = (Router)(get, "/")
@test [:bc, :ac] == logs
empty!(logs)

before(render, Text/ALayout) do text
    push!(logs, :bvl)
end
before(render, Text) do text
    push!(logs, :bv)
end
after(render, Text) do text
    push!(logs, :av)
end
after(render, Text/ALayout) do text
    push!(logs, :avl)
end

port = Bukdu.start(:any)
resp1 = Requests.get(URI("http://localhost:$port/"))
@test 200 == statuscode(resp1)
@test "hello world" == text(resp1)
@test [:br,:bc,:bvl,:bv,:av,:avl,:ac,:ar] == logs
sleep(0.1)
Bukdu.stop()

end # module test_server
