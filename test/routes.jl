using Test
using Bukdu

struct UserController <: ApplicationController
    conn::Conn
end

index(::UserController) = "hello"

# Router() do
#    resources("/users", UserController, only=[index, show])
# end

Router() do
    get("/", UserController, index)
end
