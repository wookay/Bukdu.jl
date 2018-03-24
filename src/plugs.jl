module Plug # module Bukdu

abstract type AbstractPlug end

include("plugs/static.jl")

function plug(::Type{T}; kwargs...) where {T <: AbstractPlug}
end

end # module Bukdu.Plug

export Plug, plug

import .Plug: plug

# module Bukdu
