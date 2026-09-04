module Bukdu

using TOML
using HTTP: HTTP as HT

const BUKDU_VERSION = VersionNumber(TOML.parsefile(normpath(@__DIR__, "../Project.toml"))["version"])

export Conn, ApplicationController
export JSON, Text
include("types.jl")

export render
include("render.jl")

export get, post
export routes
include("routes.jl")

include("server.jl")
include("Actions.jl")

end # module Bukdu
