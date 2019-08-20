if isempty(ARGS)
    using Bukdu
    @info :BUKDU_VERSION Bukdu.BUKDU_VERSION
end

using Jive
runtests(@__DIR__, node1=["bukdu/plugs/loggers"])
