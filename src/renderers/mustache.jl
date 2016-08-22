import Mustache

function template(path::String, params::Dict)
    contents = chomp(readstring(path))
    Mustache.render(contents, params)
end

function render{AV<:ApplicationView}(V::Type{AV}, path::String; kw...)
    LayoutT = first(V.parameters)
    params = Dict(kw)
    if isa(LayoutT, TypeVar)
        LayoutT = Void
        V = V{LayoutT}
    end
    view = V(path, params, "")
    T = typeof(view)
    if method_exists(before, (T,))
        before(view)
    end
    body = template(path, params)
    if method_exists(layout, (LayoutT,String,Dict))
        data = layout(LayoutT(), body, params)
    else
        data = body
    end
    view.data = data
    if method_exists(after, (T,))
        after(view)
    end
    data
end
