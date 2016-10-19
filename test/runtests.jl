all_tests = []
for (root, dirs, files) in walkdir(".")
    for filename in files
        !endswith(filename, ".jl") && continue
        "runtests.jl" == filename && continue
        filepath = replace(joinpath(root, filename), "./", "")
        push!(all_tests, filepath)
    end
end

for (idx, filepath) in enumerate(all_tests)
    numbering = string(idx, /, length(all_tests))
    ts = Base.Test.@testset "$numbering $filepath" begin
        include(filepath)
        Bukdu.reset()
    end
    isdefined(Base.Test, :print_test_results) && Base.Test.print_test_results(ts)
end
