module test_controller

importall Bukdu
import Bukdu: MissingConnError
import Base.Test: @test, @test_throws

immutable WelcomeController <: ApplicationController
    conn::Conn
end

index(::WelcomeController) = "hello world"
foo(::WelcomeController) = "bar"

Router() do
    get("/", WelcomeController, index)
    get("/foobar", WelcomeController, foo)
end


logs = []
before(::WelcomeController) = push!(logs, :b)
after(::WelcomeController) = push!(logs, :a)
conn = (Router)(get, "/")
@test [:b, :a] == logs

conn = (Router)(get, "/foobar")
@test 200 == conn.status
@test "bar" == conn.resp_body
@test [:b, :a, :b, :a] == logs

c = WelcomeController(Conn())
@test Assoc() == c[:query_params]
@test_throws KeyError c[:invalid_key]

type SimpleController <: ApplicationController
end

s = SimpleController()
@test_throws MissingConnError s[:query_params]
@test_throws MissingConnError s[:invalid_key]

end # module test_controller
