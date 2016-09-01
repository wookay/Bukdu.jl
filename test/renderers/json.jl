importall Bukdu

type UserController <: ApplicationController
end

index(::UserController) = render(JSON, "hello")

Router() do
    scope("/api") do
        resources("/users", UserController)
    end
end


using Base.Test
conn = (Router)(get, "/api/users")
@test 200 == conn.status
@test "application/json" == conn.resp_header["Content-Type"]
@test """\"hello\"""" == conn.resp_body

import HttpCommon: Request, Response
req = Request()
req.method = "GET"
req.resource = "/api/users"
res = Bukdu.handler(req, Response())
@test 200 == res.status
@test "application/json" == res.headers["Content-Type"]
@test """\"hello\"""" == String(res.data)

logs = []
before(render, JSON) do t
    push!(logs, "b $t")
end
after(render, JSON) do t
    push!(logs, "a $t")
end

conn = (Router)(get, "/api/users")
@test ["b hello", "a hello"] == logs

layout(::Layout, body, options) = """[$body]"""
show(::UserController) = render(JSON/Layout, "hello")
before(render, JSON/Layout) do t
    push!(logs, "bl $t")
end
after(render, JSON/Layout) do t
    push!(logs, "al $t")
end

empty!(logs)
req.method = "GET"
req.resource = "/api/users/1"
res = Bukdu.handler(req, Response())
@test 200 == res.status
@test "application/json" == res.headers["Content-Type"]
@test "[\"hello\"]" == String(res.data)
@test ["bl hello","b hello","a hello","al hello"] == logs
