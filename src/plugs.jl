module Plug # module Bukdu

using ..Deps
using ..Bukdu: Assoc, AbstractPlug, ApplicationController, AbstractRender, Render

include("plugs/logger.jl")
include("plugs/conn.jl")

include("plugs/Parsers.jl")
include("plugs/static.jl")

# pipeline plugs
include("plugs/auth.jl")
include("plugs/csrf_protection.jl")


function plug(::Type{T}; kwargs...) where {T <: AbstractPlug}
end

end # module Bukdu.Plug

export Plug, Conn, ApplicationController, Render, plug

using .Plug: Conn, ApplicationController, AbstractPlug, AbstractRender, Render
import .Plug: plug

# module Bukdu
