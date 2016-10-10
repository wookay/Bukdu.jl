importall Bukdu
import HttpCommon: Cookie
import Requests: URI, text, statuscode

type CookieController <: ApplicationController
end

show(c::CookieController) =
    render(HTML,
        Tag.form_for(nothing, action=create, method=post) do f
           string(
               Tag.hidden_csrf_token(c),
               Tag.submit("Submit")
           )
        end
    )

create(::CookieController) = :ok

Router() do
    get("/", CookieController, show)
    post("/create", CookieController, create)
end

Endpoint() do
    plug(Plug.CSRFProtection)
    plug(Router)
end


using Base.Test

Bukdu.start(8082)

resp1 = Requests.get(URI("http://localhost:8082/"))

resp_cookies = resp1.cookies
@test !isempty(resp_cookies)
key = first(keys(resp_cookies))
cookie = resp_cookies[key]
@test cookie.name == key

token = match(r"hidden\" value=\"(?P<value>[^\"]*)\"", text(resp1))[:value]
@test !isempty(token)

cookies = Vector{Cookie}(collect(values(resp_cookies)))
@test_throws Plug.InvalidCSRFTokenError (Router)(post, "/create", Assoc(), cookies)

Logger.set_level(:fatal)
resp5 = Requests.post(URI("http://localhost:8082/create"), cookies=resp1.cookies, data=Dict("_csrf_token"=>""))
@test 403 == statuscode(resp5)
@test isempty(resp5.cookies)

Logger.set_level(:info)
resp2 = Requests.post(URI("http://localhost:8082/create"), cookies=resp1.cookies, data=Dict("_csrf_token"=>token))
@test 200 == statuscode(resp2)
@test isempty(resp2.cookies)

resp3 = Requests.post(URI("http://localhost:8082/create"), cookies=resp1.cookies, data=Dict("_csrf_token"=>token))
@test isempty(resp2.cookies)
@test 200 == statuscode(resp3)

sleep(0.1)
Bukdu.stop()
