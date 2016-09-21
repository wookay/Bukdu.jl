# module Bukdu

include("renderers/text.jl")
include("renderers/json.jl")
include("renderers/html.jl")
include("renderers/markdown.jl")
include("renderers/mustache.jl")

module ViewFilter
filters = Dict()
end # module Bukdu.ViewFilter

for func in [plugins, before, after]
    name = Base.function_name(func)
    function add_view_filter(block::Function, render_func::Function, typ_name)
        params = tuple(methods(block).mt.defs.func.sig.parameters[2:end]...)
        key = (render_func,typ_name,params)
        ViewFilter.filters[(func,key)] = block
    end
    @eval begin
        function $name{AL<:ApplicationLayout}(block::Function, render_func::Function, D::LayoutDivision{AL})
            typ_name = viewlayout_symbol(D)
            $add_view_filter(block,render_func,typ_name)
        end

        function $name(block::Function, render_func::Function, modul::Module)
            typ_name = Val{Base.module_name(modul)}
            $add_view_filter(block,render_func,typ_name)
        end

        function $name(block::Function, render_func::Function, T::Type)
            typ_name = T.name.name
            $add_view_filter(block,render_func,typ_name)
        end
    end
end


function filtering(render_block::Function, render_func::Function, T::Type, args...)
    typ_name = (:Val == T.name.name) ? T : T.name.name
    params = map(x->Any, args)
    key = (render_func,typ_name,params)
    if haskey(ViewFilter.filters, (plugins,key))
        ViewFilter.filters[(plugins,key)](args...)
    end
    if haskey(ViewFilter.filters, (before,key))
        f = ViewFilter.filters[(before,key)]
        ViewFilter.filters[(before,key)](args...)
    end
    data = render_block()
    if haskey(ViewFilter.filters, (after,key))
        ViewFilter.filters[(after,key)](args...)
    end
    data
end

function render(modul::Module, args...; kw...)
    V = Val{Base.module_name(modul)}
    render(V, args...; kw...)
end

function render{AL<:ApplicationLayout}(D::LayoutDivision{AL}, args...; kw...)
    V = isa(D.dividend, Module) ? Val{Base.module_name(D.dividend)} : D.dividend
    L = D.divisor
    params = map(x->Any,args)
    key = (render,viewlayout_symbol(D),params)
    if haskey(ViewFilter.filters, (plugins,key))
        ViewFilter.filters[(plugins,key)](args...)
    end
    if haskey(ViewFilter.filters, (before,key))
        ViewFilter.filters[(before,key)](args...)
    end
    body = render(V, args...; kw...)
    body_conn = isa(body, Conn) ? body.resp_body : body
    if isempty(kw)
        bodies = tuple(body_conn, args[2:end]...)
    else
        if method_exists(layout, tuple(L, Any, typeof.(args)..., Dict))
            bodies = tuple(body_conn, args..., Dict(kw))
        else
            bodies = tuple(body_conn, args...)
        end
    end
    if isa(body, Conn)
        body.resp_body = layout(L(), bodies...)
        data = body
    else
        data = layout(L(), bodies...)
    end
    if haskey(ViewFilter.filters, (after,key))
        ViewFilter.filters[(after,key)](args...)
    end
    data
end
