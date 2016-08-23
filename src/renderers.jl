# parent module Bukdu

include("renderers/mustache.jl")
include("renderers/json.jl")
include("renderers/markdown.jl")

function render(modul::Module, obj::Any)
    V = Val{Base.module_name(modul)}
    if method_exists(before, (Type{V},))
        before(V)
    end
    data = render(V, obj)
    if method_exists(before, (Type{V},))
        after(V)
    end
    data
end

function render{AL<:ApplicationLayout}(D::LayoutDivision{AL}, obj::Any)
    V = isa(D.dividend, Module) ? Val{Base.module_name(D.dividend)} : D.dividend
    if method_exists(before, (Type{V},))
        before(V)
    end
    data = render(V, D.divisor, obj)
    if method_exists(before, (Type{V},))
        after(V)
    end
    data
end

function render{AL<:ApplicationLayout}(D::LayoutDivision{AL}; kw...)
    V = isa(D.dividend, Module) ? Val{Base.module_name(D.dividend)} : D.dividend
    if method_exists(before, (Type{V},))
        before(V)
    end 
    data = render(V, D.divisor; kw...)
    if method_exists(after, (Type{V},))
        after(V)
    end
    data
end
