__precompile__(true)

module Bukdu

include("logging.jl")
include("assoc.jl")
include("types.jl")
include("naming.jl")
include("routing.jl")
include("server.jl")
include("repr.jl")
include("runtime.jl")
include("controller.jl")

include("form_data.jl")
include("routes.jl")
include("pipelines.jl")
include("actions.jl")
include("resources.jl")

include("render.jl")
include("plugs.jl")

include("changeset.jl")
include("html5.jl")

function __init__()
    global_logger(BukduLogger())
end

end # module Bukdu
