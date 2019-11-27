module test_bukdu_plugs_prequisite_plugs

using Test

using Bukdu
@test length(Bukdu.bukdu_env[:prequisite_plugs]) == 1

empty!(Bukdu.bukdu_env[:prequisite_plugs])

using Bukdu
@test length(Bukdu.bukdu_env[:prequisite_plugs]) == 0

plug(Plug.Head)
@test length(Bukdu.bukdu_env[:prequisite_plugs]) == 1

end # module test_bukdu_plugs_prequisite_plugs
