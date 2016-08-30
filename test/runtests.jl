workspace()
Base.Test.@testset "controller.jl" begin
    include("controller.jl")
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
Base.Test.@testset "renderers/text.jl" begin
    include("renderers/mustache.jl")
end

workspace()
Base.Test.@testset "renderers/json.jl" begin
    include("renderers/json.jl")
end

workspace()
Base.Test.@testset "renderers/markdown.jl" begin
    include("renderers/markdown.jl")
end

workspace()
Base.Test.@testset "renderers/mustache.jl" begin
    include("renderers/mustache.jl")
end

workspace()
Base.Test.@testset "router.jl" begin
    include("router.jl")
end

workspace()
Base.Test.@testset "config.jl" begin
    include("config.jl")
end

workspace()
Base.Test.@testset "plugins.jl" begin
    include("plugins.jl")
end

workspace()
Base.Test.@testset "plug/static.jl" begin
    include("plug/static.jl")
end

workspace()
Base.Test.@testset "server.jl" begin
    include("server.jl")
end
