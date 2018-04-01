__precompile__(true)

module Bukdu

include("logging.jl")
include("assoc.jl")
include("Deps.jl")
include("types.jl")
include("Naming.jl")
include("render.jl")
include("System.jl")

export Routing
include("Routing.jl")
include("server.jl")
include("repr.jl")
include("Runtime.jl")
include("controller.jl")
include("routes.jl")

export Router
include("Router.jl")
include("pipelines.jl")
include("Actions.jl")
include("resources.jl")

include("plugs.jl")

include("changeset.jl")
include("HTML5.jl")

export Utils
include("Utils.jl")

export CLI
include("CLI.jl")
# include("Assembly.jl")

function __init__()
    global_logger(BukduLogger())
end

end # module Bukdu
