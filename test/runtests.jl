if isempty(ARGS)
    using Bukdu
    @info :BUKDU_VERSION Bukdu.BUKDU_VERSION
end

using Jive
skip = ["json"]
runtests(@__DIR__, skip=skip)
