# module Bukdu

# HTTP.queryparams HTTP.URI
function Base.getproperty(c::C, prop::Symbol) where {C <: ApplicationController}
    if :params == prop
        query_params = HTTP.queryparams(HTTP.URI(c.conn.request.target))
        Assoc(merge(c.conn.path_params, query_params))
    else
        getfield(c, prop)
    end
end

# module Bukdu
