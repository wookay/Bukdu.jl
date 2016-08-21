using Base.Test
using Bukdu
import JSON: json

type UserController <: ApplicationController
end

index(::UserController) = json("hello")


type Router <: ApplicationRouter
end

Router() do
    scope("/api") do
        resource("/users", UserController)
    end
end

conn = (Router)(index, "/api/users")
@test conn.status == 200
