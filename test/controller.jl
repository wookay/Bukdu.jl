importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"
foo(::WelcomeController) = "bar"

Router() do
    get("/", WelcomeController, index)
    get("/foobar", WelcomeController, foo)
end


using Base.Test
logs = []
before(::WelcomeController) = push!(logs, :b)
after(::WelcomeController) = push!(logs, :a)
conn = (Router)(index, "/")
@test [:b, :a] == logs

conn = (Router)(foo, "/foobar")
@test 200 == conn.status
@test "bar" == conn.resp_body
@test [:b, :a, :b, :a] == logs

c = WelcomeController()
@test_throws ErrorException c[:query_params]
@test_throws KeyError c[:invalid_key]
