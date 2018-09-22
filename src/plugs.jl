module Plug # module Bukdu

using ..Deps
using ..Bukdu: Assoc

"""
    ApplicationController
"""
abstract type ApplicationController end
abstract type AbstractPlug end
abstract type AbstractRender end

"""
    Render <: AbstractRender
"""
struct Render <: AbstractRender
    content_type::String
    body::Vector{UInt8}
end

include("plugs/logger.jl")
include("plugs/conn.jl")

struct EventStream <: AbstractRender
    content_type::String
    body::Vector{UInt8}
end

include("plugs/Parsers.jl")
include("plugs/static.jl")
include("plugs/websocket.jl")
include("plugs/server_sent_events.jl")

# pipeline plugs
include("plugs/csrf_protection.jl")
include("plugs/auth.jl")


function plug(::Type{T}; kwargs...) where {T <: AbstractPlug}
end

end # module Bukdu.Plug

export Plug, Conn, ApplicationController, Render, EventStream, plug

using .Plug: Conn, ApplicationController, AbstractPlug, AbstractRender, Render, EventStream
import .Plug: plug

# module Bukdu
