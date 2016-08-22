importall Bukdu

type UserController <: ApplicationController
end

index(::UserController) = render(JSON, "hello")

Router() do
    scope("/api") do
        resource("/users", UserController)
    end
end


using Base.Test
conn = (Router)(index, "/api/users")
@test 200 == conn.status
@test "application/json" == conn.resp_header["content-type"]
@test """\"hello\"""" == conn.resp_body
