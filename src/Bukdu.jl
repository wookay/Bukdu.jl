module Bukdu

using TOML
using HTTP: HTTP as HT

const BUKDU_VERSION = VersionNumber(TOML.parsefile(normpath(@__DIR__, "../Project.toml"))["version"])

export ApplicationController
export JSON, Text
export routes
export render
export get, post
export Conn
include("Actions.jl")
include("types.jl")
include("server.jl")
include("render.jl")

end # module Bukdu
