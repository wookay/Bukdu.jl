import Mustache

function template(path::String, options::Dict)
    contents = chomp(readstring(path))
    Mustache.render(contents, options)
end

function render{AV<:ApplicationView}(V::Type{AV}, path::String; kw...)
    LayoutT = first(V.parameters)
    options = Dict(kw)
    if isa(LayoutT, TypeVar)
        LayoutT = Void
        V = V{LayoutT}
    end
    view = V(path, options, "")
    T = typeof(view)
    if method_exists(before, (T,))
        before(view)
    end
    body = template(path, options)
    if method_exists(layout, (LayoutT,String,Dict))
        data = layout(LayoutT(), body, options)
    else
        data = body
    end
    view.data = data
    if method_exists(after, (T,))
        after(view)
    end
    data
end
