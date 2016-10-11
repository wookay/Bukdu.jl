module test_router_scope

importall Bukdu
import Bukdu: NoRouteError
import Base.Test: @test, @test_throws, @testset

# from phoenix/test/phoenix/router/scope_test.exs

module Api
module V1

importall Bukdu

type UserController <: ApplicationController
    conn::Conn
end

show(::UserController) = "api v1 users show"
delete(::UserController) = "api v1 users delete"
edit(::UserController) = "api v1 users edit"
foo_host(c::UserController) ="foo request from $(c[:host])"
baz_host(c::UserController) = "baz request from $(c[:host])"

type VenueController <: ApplicationController
end

end # module Api.V1
end # module Api


Base.rem(k::Symbol, v::String) = Dict{Symbol,Any}(k=>v)
Router() do
    foo_host = Api.V1.foo_host
    baz_host = Api.V1.baz_host

    scope("/admin", host= "baz.") do
        get("/users/:id", Api.V1.UserController, baz_host)
    end

    scope(host= "foobar.com") do
        scope("/admin") do
            get("/users/:id", Api.V1.UserController, foo_host)
        end
    end

    scope("/admin") do
        get("/users/:id", Api.V1.UserController, show)
    end

    scope("/api") do
        scope("/v1") do
            get("/users/:id", Api.V1.UserController, show)
        end
    end

    scope("/api", Api, private= %(:private_token, "foo")) do
        V1 = Api.V1
        get("/users", V1.UserController, show)
        get("/users/:id", V1.UserController, show, private= %(:private_token, "bar"))

        scope("/v1", alias= V1) do
            UserController = V1.UserController
            resources("/users", UserController, only= [delete], private= %(:private_token, "baz"))
        end
    end

    scope("/assigns", Api, assigns= %(:assigns_token, "foo")) do
        V1 = Api.V1
        get("/users", V1.UserController, show)
        get("/users/:id", V1.UserController, show, assigns= %(:assigns_token, "bar"))

        scope("/v1", alias= V1) do
            UserController = V1.UserController
            resources("/users", UserController, only= [delete], assigns= %(:assigns_token, "baz"))
        end
    end

    scope("/host", host= "baz.") do
        get("/users/:id", Api.V1.UserController, baz_host)
    end

    scope(host= "foobar.com") do
        scope("/host") do
            get("/users/:id", Api.V1.UserController, foo_host)
        end
    end

    scope("/api") do
        scope("/v1", Api) do
            V1 = Api.V1
            resources("/venues", V1.VenueController, only= [show], alias= V1) do
                UserController = V1.UserController
                resources("/users", UserController, only= [edit])
            end
        end
    end
end

Endpoint() do
    plug(Plug.Logger, level=:error)
    plug(Router)
end


@testset "single scope for single routes" begin
    conn = (Router)(get, "/admin/users/1")
    @test conn.status == 200
    @test conn.resp_body == "api v1 users show"
    @test conn.params[:id] == "1"

    conn = (Router)(get, "/api/users/13")
    @test conn.status == 200
    @test conn.resp_body == "api v1 users show"
    @test conn.params[:id] == "13"
end

@testset "double scope for single routes" begin
    conn = (Router)(get, "/api/v1/users/1")
    @test conn.status == 200
    @test conn.resp_body == "api v1 users show"
    @test conn.params[:id] == "1"
end

@testset "scope for resources" begin
    conn = (Router)(delete, "/api/v1/users/12")
    @test conn.status == 200
    @test conn.resp_body == "api v1 users delete"
    @test conn.params[:id] == "12"
end

@testset "scope for double nested resources" begin
    conn = (Router)(get, "/api/v1/venues/12/users/13/edit")
    @test conn.status == 200
    @test conn.resp_body == "api v1 users edit"
    @test conn.params[:venue_id] == "12"
    @test conn.params[:id] == "13"
end

@testset "host scopes routes based on conn.host" begin
    conn = (Router)(get, "http://foobar.com/admin/users/1")
    @test conn.status == 200
    @test conn.resp_body == "foo request from foobar.com"
    @test conn.params[:id] == "1"
end

@testset "host scopes allows partial host matching" begin
    conn = (Router)(get, "http://baz.bing.com/admin/users/1")
    @test conn.status == 200
    @test conn.resp_body == "baz request from baz.bing.com"

    conn = (Router)(get, "http://baz.pang.com/admin/users/1")
    @test conn.status == 200
    @test conn.resp_body == "baz request from baz.pang.com"
end

@testset "host 404s when failed match" begin
    conn = (Router)(get, "http://foobar.com/host/users/1")
    @test conn.status == 200

    conn = (Router)(get, "http://baz.pang.com/host/users/1")
    @test conn.status == 200

    @test_throws NoRouteError (Router)(get, "http://foobar.com.br/host/users/1")
    @test_throws NoRouteError (Router)(get, "http://ba.pang.com/host/users/1")
end

@testset "private data in scopes" begin
    conn = (Router)(get, "/api/users")
    @test conn.status == 200
    @test conn.private[:private_token] == "foo"

    conn = (Router)(get, "/api/users/13")
    @test conn.status == 200
    @test conn.private[:private_token] == "bar"

    conn = (Router)(delete, "/api/v1/users/13")
    @test conn.status == 200
    @test conn.private[:private_token] == "baz"
end

@testset "assigns data in scopes" begin
    conn = (Router)(get, "/assigns/users")
    @test conn.status == 200
    @test conn.assigns[:assigns_token] == "foo"

    conn = (Router)(get, "/assigns/users/13")
    @test conn.status == 200
    @test conn.assigns[:assigns_token] == "bar"

    conn = (Router)(delete, "/assigns/v1/users/13")
    @test conn.status == 200
    @test conn.assigns[:assigns_token] == "baz"
end

end # module test_router_scope
