module Bukdu

const _version_line = "version = \""
const BUKDU_VERSION = VersionNumber(strip(in(_version_line), first(filter(startswith(_version_line), readlines(normpath(@__DIR__, "../Project.toml"))))))

include("assoc.jl")
include("Deps.jl")
include("Actions.jl")
include("types.jl")

const bukdu_env = Dict{Symbol, Any}(
    :server => nothing,
    :prequisite_plugs => Vector{Function}(),
)

include("plugs.jl")
include("Naming.jl")
include("render.jl")
include("System.jl")

export Routing
include("Routing.jl")
include("server.jl")

export redirect_to
include("controller.jl")
include("routes.jl")

export Router
include("Router.jl")
include("pipelines.jl")
include("resources.jl")

include("changeset.jl")
include("HTML5.jl")

export Utils
include("Utils.jl")

export CLI
include("CLI.jl")
# include("Assembly.jl")

function __init__()
    plug(Plug.Loggers.DefaultLogger)
    plug(Plug.Head)
end

end # module Bukdu
