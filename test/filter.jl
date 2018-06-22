module test_filter

importall Bukdu
import Base.Test: @test, @test_throws

type WelcomeController <: ApplicationController
    conn::Conn
end

show(::WelcomeController) = nothing
create(::WelcomeController) = nothing
secret(::WelcomeController) = nothing

Router() do
    get("/", WelcomeController, show)
    post("/", WelcomeController, create)
    patch("/", WelcomeController, secret)
end


logs = []
function before(c::WelcomeController)
    push!(logs, c[:private][:action])
end

conn = (Router)(get, "/")
@test 200 == conn.status
@test [show] == logs

conn = (Router)(post, "/")
@test 200 == conn.status
@test [show, create] == logs

conn = (Router)(patch, "/")
@test 200 == conn.status
@test [show, create, secret] == logs

end # module test_filter
