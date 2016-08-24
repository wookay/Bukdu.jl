# parent module Bukdu

include("renderers/mustache.jl")
include("renderers/json.jl")
include("renderers/text.jl")
include("renderers/markdown.jl")

module ViewFilter
filters = Dict()
end

function before{AL<:ApplicationLayout}(block::Function, func::Function, D::LayoutDivision{AL})
    before(block, func, typeof(D))
end

function before(block::Function, func::Function, modul::Module)
    typ = Val{Base.module_name(modul)}
    before(block, func, typ)
end

function before(block::Function, func::Function, typ::Type)
    ViewFilter.filters[(before,func,typ)] = block
end

function after{AL<:ApplicationLayout}(block::Function, func::Function, D::LayoutDivision{AL})
    after(block, func, typeof(D))
end

function after(block::Function, func::Function, modul::Module)
    typ = Val{Base.module_name(modul)}
    after(block, func, typ)
end

function after(block::Function, func::Function, typ::Type)
    ViewFilter.filters[(after,func,typ)] = block
end

function filtering(block::Function, func::Function, T::Type, obj::Any)
    key = (before,func,T)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    data = block()
    key = (after,func,T)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    data
end

function filtering(block::Function, func::Function, T::Type; kw...)
    vals = map(last, kw)
    key = (before,func,T)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    data = block()
    key = (after,func,T)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    data
end

function render(modul::Module, obj::Any)
    V = Val{Base.module_name(modul)}
    render(V, obj)
end

function render(modul::Module; kw...)
    V = Val{Base.module_name(modul)}
    render(V; kw...)
end

function render{AL<:ApplicationLayout}(D::LayoutDivision{AL}, obj::Any)
    V = isa(D.dividend, Module) ? Val{Base.module_name(D.dividend)} : D.dividend
    L = D.divisor
    options = Dict()
    key = (before,render,typeof(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    body = render(V, obj)
    data = method_exists(layout, (L,String,Dict)) ? draw_layout(L, body, options) : body
    key = (after,render,typeof(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    data
end

function render{AL<:ApplicationLayout}(D::LayoutDivision{AL}; kw...)
    V = isa(D.dividend, Module) ? Val{Base.module_name(D.dividend)} : D.dividend
    L = D.divisor
    options = Dict(kw)
    vals = map(last, kw)
    key = (before,render,typeof(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    body = render(V; kw...)
    data = method_exists(layout, (L,String,Dict)) ? draw_layout(L, body, options) : body
    key = (after,render,typeof(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    data
end
