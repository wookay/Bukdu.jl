abstract ApplicationView{T}

type View{T} <: ApplicationView{T}
    path::String
    params::Dict
    data::String
end


# renderers/
include("renderers/mustache.jl")
include("renderers/json.jl")


# layout
"""
layout(::Layout, body, params)
"""
function layout
end
