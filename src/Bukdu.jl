__precompile__(true)

module Bukdu

include("logging.jl")
include("assoc.jl")
include("Deps.jl")
include("plugs.jl")
include("types.jl")
include("Naming.jl")
include("render.jl")
include("System.jl")

export Routing
include("Routing.jl")
include("server.jl")
include("repr.jl")
include("controller.jl")
include("routes.jl")

export Router
include("Router.jl")
include("pipelines.jl")
include("Actions.jl")
include("resources.jl")


include("changeset.jl")
include("HTML5.jl")

export Utils
include("Utils.jl")

export CLI
include("CLI.jl")
# include("Assembly.jl")

function __init__()
    global_logger(Bukdu.Logger())
end

end # module Bukdu
