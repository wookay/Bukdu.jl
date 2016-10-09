# module Bukdu

function Base.show{AE<:ApplicationError}(io::IO, ex::AE)
    write(io, string(AE.name.name, "(\"", ex.message, "\")"))
end
