# module Bukdu

include("renderers/layout.jl")
include("renderers/view.jl")

include("renderers/text.jl")
include("renderers/json.jl")
include("renderers/html.jl")
include("renderers/markdown.jl")
include("renderers/mustache.jl")

module ViewFilter
filters = Dict()
end # module Bukdu.ViewFilter


for func in [before, after]
    function add_view_filter(block::Function, render_func::Function, typ_name)
        params = tuple(methods(block).mt.defs.func.sig.parameters[2:end]...)
        key = (render_func, typ_name, params)
        ViewFilter.filters[(func, key)] = block
    end

    name = Base.function_name(func)
    @eval begin
        function $name{AL<:ApplicationLayout}(block::Function, render_func::Function, D::LayoutDivision{AL})
            typ_name = viewlayout_symbol(D)
            $add_view_filter(block, render_func, typ_name)
        end

        function $name(block::Function, render_func::Function, modul::Module)
            typ_name = Val{Base.module_name(modul)}
            $add_view_filter(block, render_func, typ_name)
        end

        function $name(block::Function, render_func::Function, T::Type)
            typ_name = Base.datatype_name(T)
            $add_view_filter(block, render_func, typ_name)
        end
    end
end

function filtering(render_block::Function, render_func::Function, T::Type, args...)::Conn
    typ_name = (:Val == Base.datatype_name(T)) ? T : Base.datatype_name(T)
    params = map(x->Any, args)
    key = (render_func, typ_name, params)
    if haskey(ViewFilter.filters, (before, key))
        f = ViewFilter.filters[(before, key)]
        ViewFilter.filters[(before, key)](args...)
    end
    conn = render_block()
    if haskey(ViewFilter.filters, (after, key))
        ViewFilter.filters[(after, key)](args...)
    end
    conn
end

function render(modul::Module, args...; kw...)::Conn
    V = Val{Base.module_name(modul)}
    render(V, args...; kw...)
end

function render{AL<:ApplicationLayout}(D::LayoutDivision{AL}, args...; kw...)::Conn
    V = isa(D.dividend, Module) ? Val{Base.module_name(D.dividend)} : D.dividend
    L = D.divisor
    params = map(x->Any, args)
    key = (render, viewlayout_symbol(D), params)
    if haskey(ViewFilter.filters, (before, key))
        ViewFilter.filters[(before, key)](args...)
    end
    conn::Conn = render(V, args...; kw...)
    conn_body = conn.resp_body
    if isempty(kw)
        bodies = tuple(conn_body, args[2:end]...)
    else
        argstuple = isempty(args) ? tuple() : map(typeof, args)
        if method_exists(layout, tuple(L, Any, argstuple..., Dict))
            bodies = tuple(conn_body, args..., Dict(kw))
        else
            bodies = tuple(conn_body, args...)
        end
    end
    conn.resp_body = layout(L(), bodies...)
    if haskey(ViewFilter.filters, (after, key))
        ViewFilter.filters[(after, key)](args...)
    end
    conn
end
