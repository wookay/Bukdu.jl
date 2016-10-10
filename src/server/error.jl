# module Bukdu

function Base.show{AE<:ApplicationError}(io::IO, ex::AE)
    # don't show ex.conn
    write(io, string(AE.name.name, "(\"", ex.message, "\")"))
end
