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
    resource("/pages", PageController) do
        resource("/users", UserController)
    end
end


using Base.Test
conn = (Router)(index, "/pages")
@test conn.status == 200
@test conn.resp_body == "index page"

conn = (Router)(show, "/pages/1")
@test conn.status == 200
@test conn.resp_body == 1
@test conn.params["id"] == "1"

conn = (Router)(index, "/pages/1/users")
@test conn.status == 200
@test conn.resp_body == "index user"
@test conn.params["page_id"] == "1"
@test !haskey(conn.params, "id")

conn = (Router)(show, "/pages/1/users/2")
@test conn.status == 200
@test conn.resp_body == Dict("page_id"=>"1","id"=>"2")
@test conn.params["page_id"] == "1"
@test conn.params["id"] == "2"

conn = (Router)(delete, "/pages/1")
@test conn.status == 200

conn = (Router)(show, "/unknown/1")
@test conn.status == 404

reset(Router)

conn = (Router)(index, "/pages")
@test conn.status == 404

Router() do
    resource("/pages", PageController, except=[delete], singleton=true)
    resource("/users", UserController, only=[index], singleton=true)
end

conn = (Router)(index, "/pages")
@test conn.status == 200

conn = (Router)(delete, "/pages/1")
@test conn.status == 404

conn = (Router)(index, "/users")
@test conn.status == 200

conn = (Router)(delete, "/users/1")
@test conn.status == 404
