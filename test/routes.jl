using Test
using Bukdu

struct UserController <: ApplicationController
end

Router() do
    resources("/users", UserController, only=[index, show])
end

Router() do
    get("/", UserController, index)
end
