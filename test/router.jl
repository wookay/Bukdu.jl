importall Bukdu

type PageController <: ApplicationController
end

type UserController <: ApplicationController
end

index(::PageController) = "index page"
show(c::PageController) = parse(Int, c[:params]["id"])
delete(::PageController) = nothing

index(::UserController) = "index user"
show(c::UserController) = c[:params]

Router() do
    resources("/pages", PageController) do
        resources("/users", UserController)
    end
end


Logger.set_level(false)
using Base.Test
conn = (Router)(get, "/pages")
@test conn.status == 200
@test conn.resp_body == "index page"

conn = (Router)(get, "/pages/1")
@test conn.status == 200
@test conn.resp_body == 1
@test conn.params["id"] == "1"

conn = (Router)(get, "/pages/1/users")
@test conn.status == 200
@test conn.resp_body == "index user"
@test conn.params["page_id"] == "1"
@test !haskey(conn.params, "id")

conn = (Router)(get, "/pages/1/users/2")
@test conn.status == 200
@test conn.resp_body == Dict("page_id"=>"1","id"=>"2")
@test conn.params["page_id"] == "1"
@test conn.params["id"] == "2"

conn = (Router)(delete, "/pages/1")
@test conn.status == 200

@test_throws NoRouteError (Router)(get, "/unknown/1")

reset(Router)

@test_throws NoRouteError (Router)(get, "/pages")

Router() do
    resources("/pages", PageController, except=[delete], singleton=true)
    resources("/users", UserController, only=[index], singleton=true)
end

conn = (Router)(get, "/pages")
@test conn.status == 200

@test_throws NoRouteError (Router)(delete, "/pages/1")

conn = (Router)(get, "/users")
@test conn.status == 200

@test_throws NoRouteError (Router)(delete, "/users/1")
