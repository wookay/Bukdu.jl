module test_bukdu_assoc

using Test
using Bukdu: Assoc

assoc = Assoc("A" => "B")
@test !isempty(assoc)

@test pairs(["A" => "B"]) == pairs(assoc)

params = Assoc("x" => "2")
@test haskey(params, :x)
@test get(params, :x, 0) == 2
@test something(params.x, "") == "2"
@test params.x == "2"
@test params[:x] == "2"
@test params["x"] == "2"

@test !haskey(params, :y)
@test get(params, :y, 3) == 3
@test something(params.y, "") === ""
@test params.y === nothing
@test params[:y] === nothing
@test params["y"] === nothing

params[:x] = "3"
@test params.x == "3"
params[:y] = "5"
@test params.y == "5"
@test length(params) == 2
@test keys(params) == ["x", "y"]
@test values(params) == ["3", "5"]

empty!(params)
@test !haskey(params, "x")

buf = IOBuffer()
show(buf, MIME"text/plain"(), params)
@test String(take!(buf)) == "Bukdu.Assoc()\n"

assoc = Assoc("a" => 2, "b" => [1,2])
@test !isempty(assoc)
@test assoc.a in assoc.b

end # module test_bukdu_assoc
