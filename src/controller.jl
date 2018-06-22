# module Bukdu

function Base.getproperty(c::C, prop::Symbol) where {C <: ApplicationController}
    if prop in (:params, :query_params, :path_params, :body_params)
        getfield(c.conn, prop)
    else
        getfield(c, prop)
    end
end

# module Bukdu
