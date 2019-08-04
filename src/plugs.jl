module Plug # module Bukdu

using ..Deps
using ..Bukdu: Assoc, AbstractPlug, ApplicationController, AbstractRender, Render
using Logging: AbstractLogger

include("plugs/Loggers.jl")
include("plugs/conn.jl")
include("plugs/ContentParsers.jl")
include("plugs/parsers.jl")
include("plugs/static.jl")

function plug(::Type{T}; kwargs...) where {T <: AbstractPlug}
end

function plug(::Type{T}, args...; kwargs...) where {T <: AbstractLogger}
    Loggers.current[:logger] = T(args...; kwargs...)
end

end # module Bukdu.Plug

export Plug, Conn, ApplicationController, Render, plug

using .Plug: Conn, ApplicationController, AbstractPlug, AbstractRender, Render
import .Plug: plug

# module Bukdu
