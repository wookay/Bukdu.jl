workspace()
Base.Test.@testset "controller.jl" begin
    include("controller.jl")
end

workspace()
Base.Test.@testset "router.jl" begin
    include("router.jl")
end

workspace()
Base.Test.@testset "params.jl" begin
    include("params.jl")
end

workspace()
Base.Test.@testset "view.jl" begin
    include("view.jl")
end

workspace()
Base.Test.@testset "renderers/" begin
    include("renderers/json.jl")
    include("renderers/mustache.jl")
end

workspace()
Base.Test.@testset "server.jl" begin
    include("server.jl")
end
