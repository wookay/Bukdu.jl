using Test
using Bukdu: Assoc

assoc = Assoc("A" => "B")
@test !isempty(assoc)
