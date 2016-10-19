module test_router_endpoint

importall Bukdu
import Bukdu: NoRouteError
import HttpCommon: Cookie
import Base.Test: @test, @test_throws

Router() do
end


Logger.set_level(:error)

Bukdu.start(8082)

immutable Endpoint2 <: ApplicationEndpoint
end

Bukdu.start(Endpoint2, 8083)

sleep(0.1)
Bukdu.stop()

Bukdu.stop(Endpoint2)

immutable EndpointController <: ApplicationController
end

index(::EndpointController) = ""

Router() do
    get("/first", EndpointController, index)
end

Endpoint() do
    plug(Router)
end

immutable Router2 <: ApplicationRouter
end

Router2() do
    get("/second", EndpointController, index)
end

Endpoint2() do
    plug(Router2)
end

conn = (Router)(get, "/first")
@test 200 == conn.status

conn = (Router2)(get, "/second")
@test 200 == conn.status

conn = (Endpoint)("/first")
@test 200 == conn.status

conn = (Endpoint2)("/second")
@test 200 == conn.status

Logger.set_level(:error)
@test_throws NoRouteError (Router)(get, "/second")
@test_throws NoRouteError (Router2)(get, "/first")
@test_throws NoRouteError (Endpoint)("/second")
@test_throws NoRouteError (Endpoint2)("/first")


type WelcomeController <: ApplicationController
end

first(::WelcomeController) = 1
second(::WelcomeController) = 2

@test_throws NoRouteError (Endpoint)("/")

Router() do
    get("/", WelcomeController, first)
end

@test !isempty(Bukdu.Routing.routes)

conn = (Router)(get, "/")
@test 200 == conn.status

@test_throws NoRouteError (Endpoint)("/")


type SecondRouter <: ApplicationRouter
end

SecondRouter() do
end

@test isempty(Bukdu.Routing.routes)

SecondRouter() do
    get("/", WelcomeController, second)
end

@test !isempty(Bukdu.Routing.routes)

Endpoint() do
    plug(Router)
    plug(SecondRouter)
end

conn = (Router)(get, "/")
@test 200 == conn.status

conn = (SecondRouter)(get, "/")
@test 200 == conn.status

conn = (Endpoint)("/")
@test 1 == conn.resp_body

type SecondEndpoint <: ApplicationEndpoint
end

SecondEndpoint() do
    plug(SecondRouter)
    plug(Router)
end

conn = (Endpoint)("/")
@test 1 == conn.resp_body
@test Router == conn.private[:router]
@test Endpoint == conn.private[:endpoint]

conn = (SecondEndpoint)("/")
@test 2 == conn.resp_body
@test SecondRouter == conn.private[:router]
@test SecondEndpoint == conn.private[:endpoint]

type NothingRouter <: ApplicationRouter
end

type NothingEndpoint <: ApplicationEndpoint
end

NothingRouter() do
end

NothingEndpoint() do
end

@test_throws NoRouteError (NothingRouter)(get, "/")

@test_throws NoRouteError (NothingEndpoint)("/")

NothingEndpoint() do
    plug(NothingRouter)
end

@test_throws NoRouteError (NothingEndpoint)("/")

conn = (Endpoint)("/")
@test 200 == conn.status

conn = (Endpoint)("/", Assoc(), [Cookie("name","value",Dict{String,String}())])
@test !isempty(conn.req_cookies)

end # module test_router_endpoint
