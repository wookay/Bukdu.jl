importall Bukdu

type WelcomeController <: ApplicationController
end

first(::WelcomeController) = 1
second(::WelcomeController) = 2


using Base.Test
@test isempty(Bukdu.RouterRoute.routes)

conn = (Endpoint)("/")
@test 404 == conn.status

Router() do
    get("/", WelcomeController, first)
end

@test !isempty(Bukdu.RouterRoute.routes)

conn = (Endpoint)("/")
@test 404 == conn.status


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

conn = (Router)(first, "/")
@test 200 == conn.status

conn = (Router)(second, "/")
@test 404 == conn.status

conn = (SecondRouter)(first, "/")
@test 404 == conn.status

conn = (SecondRouter)(second, "/")
@test 200 == conn.status

conn = (Endpoint)("/")
@test 1 == conn.resp_body

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

conn = (NothingRouter)(first, "/")
@test 404 == conn.status

conn = (NothingEndpoint)("/")
@test 404 == conn.status

NothingEndpoint() do
    plug(NothingRouter)
end

conn = (NothingEndpoint)("/")
@test 404 == conn.status

conn = (Endpoint)("/")
@test 200 == conn.status
