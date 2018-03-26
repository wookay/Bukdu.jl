# module Bukdu.Plug

struct CSRF <: AbstractPlug
end

function plug(::Type{CSRF}, c::C) where {C<:ApplicationController}
    # TODO
    @info plug CSRF C
end

# module Bukdu.Plug
