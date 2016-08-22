importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end


using Base.Test
logs = []
before(::WelcomeController) = push!(logs, :b)
after(::WelcomeController) = push!(logs, :a)
conn = (Router)(index, "/")
@test [:b, :a] == logs
