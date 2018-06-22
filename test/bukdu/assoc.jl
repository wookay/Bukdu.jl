module test_bukdu_assoc

using Test
using Bukdu: Assoc

assoc = Assoc("A" => "B")
@test !isempty(assoc)

@test pairs(["A" => "B"]) == pairs(assoc)

params = Assoc("x" => "2")
@test get(params, :x, 0) == 2
@test get(params, :y, 3) == 3
@test !haskey(params, :a)
@test params.a == ""

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

end # module test_bukdu_assoc
