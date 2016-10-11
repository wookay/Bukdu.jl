for (root, dirs, files) in walkdir(".")
    for filename in files
        !endswith(filename, ".jl") && continue
        "runtests.jl" == filename && continue
        filepath = replace(joinpath(root, filename), "./", "")
        Base.Test.@testset "$filepath" begin
            include(filepath)
            Bukdu.reset()
        end
    end
end
