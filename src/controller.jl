export Conn

# using HTTP # HTTP.Messages HTTP.queryparams HTTP.URI

const Conn = HTTP.Messages.Request

function Base.getproperty(c::C, prop::Symbol) where {C <: ApplicationController}
    if :params == prop
        Assoc(HTTP.queryparams(HTTP.URI(c.conn.target)))
    else
        getfield(c, prop)
    end
end
