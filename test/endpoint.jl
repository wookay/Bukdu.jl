importall Bukdu

type WelcomeController <: ApplicationController
end

first(::WelcomeController) = 1
second(::WelcomeController) = 2


Logger.set_level(false)

using Base.Test
@test isempty(Bukdu.RouterRoute.routes)

@test_throws NoRouteError (Endpoint)("/")

Router() do
    get("/", WelcomeController, first)
end

@test !isempty(Bukdu.RouterRoute.routes)

conn = (Router)(get, "/")
@test 200 == conn.status

@test_throws NoRouteError (Endpoint)("/")


type SecondRouter <: ApplicationRouter
end

SecondRouter() do
end

@test isempty(Bukdu.RouterRoute.routes)

SecondRouter() do
    get("/", WelcomeController, second)
end

@test !isempty(Bukdu.RouterRoute.routes)

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

conn = (SecondEndpoint)("/")
@test 2 == conn.resp_body


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
