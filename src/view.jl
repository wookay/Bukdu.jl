abstract ApplicationView{T}

type View{T} <: ApplicationView{T}
    path::String
    options::Dict
    data::String
end


# renderers/
include("renderers/mustache.jl")
include("renderers/json.jl")
include("renderers/markdown.jl")

function render(modul::Module, obj::Any)
    render(Val{Base.module_name(modul)}, obj)
end


# layout
"""
layout(::Layout, body, options)
"""
function layout
end
