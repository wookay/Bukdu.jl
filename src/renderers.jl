# module Bukdu

include("renderers/text.jl")
include("renderers/json.jl")
include("renderers/markdown.jl")
include("renderers/mustache.jl")

module ViewFilter
filters = Dict()
end # module Bukdu.ViewFilter

for f in [plugins, before, after]
    name = Base.function_name(f)
    @eval begin
        function $name{AL<:ApplicationLayout}(block::Function, func::Function, D::LayoutDivision{AL})
            ViewFilter.filters[($f,func,layout_symbol(D))] = block
        end

        function $name(block::Function, func::Function, modul::Module)
            typ_name = Val{Base.module_name(modul)}
            ViewFilter.filters[($f,func,typ_name)] = block
        end

        function $name(block::Function, func::Function, typ::Type)
            typ_name = typ.name.name
            key = ($f,func,typ_name)
            ViewFilter.filters[key] = block
        end
    end
end


function filtering(block::Function, func::Function, T::Type, obj::Any)
    typ_name = (:Val == T.name.name) ? T : T.name.name
    key = (plugins,func,typ_name)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    key = (before,func,typ_name)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    data = block()
    key = (after,func,typ_name)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    data
end

function filtering(block::Function, func::Function, T::Type; kw...)
    vals = map(last, kw)
    typ_name = (:Val == T.name.name) ? T : T.name.name
    key = (plugins,func,typ_name)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    key = (before,func,typ_name)
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    data = block()
    key = (after,func,typ_name)
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
    key = (plugins,render,layout_symbol(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    key = (before,render,layout_symbol(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](obj)
    end
    body = render(V, obj)
    data = method_exists(layout, (L,String,Dict)) ? draw_layout(L, body, options) : body
    key = (after,render,layout_symbol(D))
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
    key = (plugins,render,layout_symbol(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    key = (before,render,layout_symbol(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    body = render(V; kw...)
    data = method_exists(layout, (L,String,Dict)) ? draw_layout(L, body, options) : body
    key = (after,render,layout_symbol(D))
    if haskey(ViewFilter.filters, key)
        ViewFilter.filters[key](vals...)
    end
    data
end
