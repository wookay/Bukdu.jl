importall Bukdu

type UserController <: ApplicationController
end

index(::UserController) = render(JSON, "hello")

Router() do
    scope("/api") do
        resource("/users", UserController)
    end
end


using Base.Test
conn = (Router)(index, "/api/users")
@test 200 == conn.status
@test "application/json" == conn.resp_header["content-type"]
@test """\"hello\"""" == conn.resp_body

import HttpCommon: Request, Response
req = Request()
req.method = "GET"
req.resource = "/api/users"
res = Bukdu.handler(req, Response())
@test 200 == res.status
@test "application/json" == res.headers["Content-Type"]
@test """\"hello\"""" == String(res.data)
