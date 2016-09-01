importall Bukdu

type WelcomeController <: ApplicationController
    stack::Vector
    WelcomeController() = new([])
end

show(c::WelcomeController) = c.stack
create(c::WelcomeController) = c.stack
secret(c::WelcomeController) = c.stack
prepend(c::WelcomeController) = push!(c.stack, (:p,c[:action]))

function plugins(c::WelcomeController)
   if c[:action] in [show, create, secret]
       plug(prepend, c)
   end
end

function before(c::WelcomeController)
    push!(c.stack, (:b,c[:action]))
end

Router() do
    get("/", WelcomeController, show)
    post("/", WelcomeController, create)
    patch("/", WelcomeController, secret)
end


using Base.Test
conn = (Router)(get, "/")
@test 200 == conn.status
@test [(:p,show),(:b,show)] == conn.resp_body

conn = (Router)(post, "/")
@test 200 == conn.status
@test [(:p,create),(:b,create)] == conn.resp_body

conn = (Router)(patch, "/")
@test 200 == conn.status
@test [(:p,secret),(:b,secret)] == conn.resp_body
