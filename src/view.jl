abstract ApplicationView{T}

type View{T} <: ApplicationView{T}
    path::String
    options::Dict
    data::String
end


# renderers/
include("renderers/mustache.jl")
include("renderers/json.jl")


# layout
"""
layout(::Layout, body, options)
"""
function layout
end
