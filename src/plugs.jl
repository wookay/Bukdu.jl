module Plug # module Bukdu

import ..Deps
import ..Assoc

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

include("plugs/conn.jl")

struct EventStream <: AbstractRender
    content_type::String
    body::Vector{UInt8}
end

include("plugs/Parsers.jl")
include("plugs/static.jl")

# pipeline plugs
include("plugs/csrf_protection.jl")
include("plugs/auth.jl")
include("plugs/websocket.jl")


function plug(::Type{T}; kwargs...) where {T <: AbstractPlug}
end

end # module Bukdu.Plug

export Plug, Conn, ApplicationController, Render, EventStream, plug

import .Plug: Conn, ApplicationController, AbstractPlug, AbstractRender, Render, EventStream, plug

# module Bukdu
