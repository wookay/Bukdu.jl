importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end


using Base.Test
import HttpCommon: Request, Response
req = Request()
req.method = "GET"
req.resource = "/"
res = Bukdu.handler(req, Response())
@test 200 == res.status
@test "hello world" == String(res.data)

req.method = "POST"
req.resource = "/"
res = Bukdu.handler(req, Response())
@test 404 == res.status

req.method = "GET"
req.resource = "/test"
res = Bukdu.handler(req, Response())
@test 404 == res.status

import Requests: get, statuscode, text
Bukdu.start([8082, 8083])
resp1 = Requests.get("http://localhost:8082/")
resp2 = Requests.get("http://localhost:8083/")
@test 200 == statuscode(resp1)
@test 200 == statuscode(resp2)
@test "hello world" == text(resp1)
@test "hello world" == text(resp2)
sleep(0.1)
Bukdu.stop()
