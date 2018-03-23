__precompile__(true)

module Bukdu

include("logging.jl")
include("types.jl")
include("server.jl")
include("repr.jl")
include("assoc.jl")
include("runtime.jl")
include("controller.jl")
include("routes.jl")
include("render.jl")

function __init__()
    global_logger(BukduLogger())
end

end # module Octo
