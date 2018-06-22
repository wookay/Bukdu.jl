module test_plug_csrf_protection

importall Bukdu
import Requests # Requests.get, Requests.post
import Requests: URI, text, statuscode
import Base.Test: @test, @test_throws

type UserController <: ApplicationController
    conn::Conn
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


port = Bukdu.start(:any)

resp1 = Requests.get(URI("http://localhost:$port/"))
token = match(r"value=\"(.*)\"", text(resp1))[1]

@test 403 == statuscode(Requests.post(URI("http://localhost:$port/post_result"), cookies=resp1.cookies, data=Dict("_csrf_token"=>"")))
@test 200 == statuscode(Requests.post(URI("http://localhost:$port/post_result"), cookies=resp1.cookies, data=Dict("_csrf_token"=>token)))
@test 200 == statuscode(Requests.post(URI("http://localhost:$port/post_result"), cookies=resp1.cookies, data=Dict("_csrf_token"=>token)))

sleep(0.1)
Bukdu.stop()

end # module test_plug_csrf_protection
