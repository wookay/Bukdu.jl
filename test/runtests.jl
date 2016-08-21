using Base.Test
@testset "router.jl" begin
    include("router.jl")
end

workspace()

using Base.Test
@testset "scope.jl" begin
    include("scope.jl")
end

workspace()

using Base.Test
@testset "view.jl" begin
    include("view.jl")
end
