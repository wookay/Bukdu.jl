module test_renderers_json

importall Bukdu
import HttpCommon: Request, Response
import JSON
import Base.Test: @test, @test_throws

type UserController <: ApplicationController
end

index(::UserController) = render(JSON, "hello")

Router() do
    scope("/api") do
        resources("/users", UserController)
    end
end


conn = (Router)(get, "/api/users")
@test 200 == conn.status
@test "application/json" == conn.resp_headers["Content-Type"]
@test """\"hello\"""" == conn.resp_body

req = Request()
req.method = "GET"
req.resource = "/api/users"
res = Bukdu.Server.handler(Endpoint, req, Response())
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

type JsonLayout <: ApplicationLayout
end
layout(::JsonLayout, body) = """[$body]"""
show(::UserController) = render(JSON/JsonLayout, "hello")
before(render, JSON/JsonLayout) do t
    push!(logs, "bl $t")
end
after(render, JSON/JsonLayout) do t
    push!(logs, "al $t")
end

empty!(logs)
req.method = "GET"
req.resource = "/api/users/1"
res = Bukdu.Server.handler(Endpoint, req, Response())
@test 200 == res.status
@test "application/json" == res.headers["Content-Type"]
@test "[\"hello\"]" == String(res.data)
@test ["bl hello","b hello","a hello","al hello"] == logs

end # module test_renderers_json
