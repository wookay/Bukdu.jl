__precompile__(true)

module Bukdu

include("logging.jl")
include("types.jl")
include("naming.jl")
include("routing.jl")
include("server.jl")
include("repr.jl")
include("assoc.jl")
include("runtime.jl")
include("controller.jl")

include("routes.jl")
include("actions.jl")
include("resources.jl")

include("render.jl")
include("plugs.jl")

function __init__()
    global_logger(BukduLogger())
end

end # module Bukdu
