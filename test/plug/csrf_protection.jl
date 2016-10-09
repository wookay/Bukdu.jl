importall Bukdu
import Requests: URI, text, statuscode

type UserController <: ApplicationController
end

function index(c::UserController)
    render(HTML, """
$(Tag.hidden_csrf_token(c))
""")
end

function post_result(::UserController)
end

Router() do
    get("/", UserController, index)
    post("/post_result", UserController, post_result)
end

Endpoint() do
    plug(Plug.Logger, level=:fatal)
    plug(Plug.CSRFProtection)
    plug(Router)
end


using Base.Test

Bukdu.start(8082)

resp1 = Requests.get(URI("http://localhost:8082/"))
token = match(r"value=\"(.*)\"", text(resp1))[1]

@test 403 == statuscode(Requests.post(URI("http://localhost:8082/post_result"), data=Dict("_csrf_token"=>"")))
@test 200 == statuscode(Requests.post(URI("http://localhost:8082/post_result"), data=Dict("_csrf_token"=>token)))
@test 200 == statuscode(Requests.post(URI("http://localhost:8082/post_result"), data=Dict("_csrf_token"=>token)))

sleep(0.1)
Bukdu.stop()
