export ApplicationView
export View
export render

import Mustache

abstract ApplicationView{T}

type View{T} <: ApplicationView{T}
    path::String
    params::Dict
    body::String
end

function template(path::String, params::Dict)
    contents = chomp(readstring(path))
    Mustache.render(contents, params)
end

type Layout
end
layout(::Layout, body, params) = body

function render{AV<:ApplicationView}(V::Type{AV}, path::String; kw...)
    LayoutT = first(V.parameters)
    params = Dict(kw)
    if isa(LayoutT, TypeVar)
        LayoutT = Layout
        V = V{LayoutT}
    end
    v = V(path, params, "")
    T = typeof(v)
    if method_exists(before, (T,))
        before(v)
    end
    body = layout(LayoutT(), template(path, params), params)
    if method_exists(after, (T,))
        after(V(path, params, body))
    end
    body
end
