module test_bukdu_assoc

using Test
using Bukdu: Assoc

assoc = Assoc("A" => "B")
@test !isempty(assoc)

@test pairs(["A" => "B"]) == pairs(assoc)

params = Assoc("x" => "2")
@test get(params, :x, 0) == 2
@test get(params, :y, 3) == 3

end # module test_bukdu_assoc
