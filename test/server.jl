importall Bukdu

type WelcomeController <: ApplicationController
end

layout(::Layout, body) = body
index(::WelcomeController) = render(Text/Layout, "hello world")
show(::WelcomeController) = pi

Router() do
    get("/", WelcomeController, index)
    get("/pi", WelcomeController, show)
end

Endpoint() do
    plug(Plug.Logger, level=:fatal)
    plug(Router)
end


using Base.Test
import HttpCommon: Request, Response

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

import Requests: URI, statuscode, text

Bukdu.start([8082, 8083])

resp1 = Requests.get(URI("http://localhost:8082/"))
resp2 = Requests.get(URI("http://localhost:8083/"))
@test 200 == statuscode(resp1)
@test 200 == statuscode(resp2)
@test "hello world" == text(resp1)
@test "hello world" == text(resp2)

req.method = "GET"
req.resource = "/"

(server,task) = first(Bukdu.Farm.servers[Endpoint])
@test :runnable == task.state
@test "hello world" == text(server.http.handle(req, Response()))

sleep(0.1)
Bukdu.stop()

logs = []

before(::Request, ::Response) = push!(logs, :br)
before(::WelcomeController) = push!(logs, :bc)
after(::WelcomeController) = push!(logs, :ac)
after(::Request, ::Response) = push!(logs, :ar)

conn = (Router)(get, "/")
@test [:bc, :ac] == logs
empty!(logs)

before(render, Text/Layout) do text
    push!(logs, :bvl)
end
before(render, Text) do text
    push!(logs, :bv)
end
after(render, Text) do text
    push!(logs, :av)
end
after(render, Text/Layout) do text
    push!(logs, :avl)
end

Bukdu.start(8082)
resp1 = Requests.get(URI("http://localhost:8082/"))
@test_throws Base.UVError Requests.get(URI("http://localhost:8083/"))
@test 200 == statuscode(resp1)
@test "hello world" == text(resp1)
@test [:br,:bc,:bvl,:bv,:av,:avl,:ac,:ar] == logs
sleep(0.1)
Bukdu.stop()
