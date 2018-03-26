# module Bukdu.Plug

struct Auth <: AbstractPlug
end

function plug(::Type{Auth}, c::C) where {C<:ApplicationController}
    # TODO
    @info plug Auth C
end

# module Bukdu.Plug
