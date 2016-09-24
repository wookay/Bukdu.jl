# module Bukdu

module Tag

export form_for, label, text_input, select, textarea, submit

import ....Bukdu
import ....Bukdu.Octo: Changeset, change

function tag_id(f, field)
    string(lowercase(string(typeof(f))), '_', field)
end

function tag_name(f, field)
    string(lowercase(string(typeof(f))), '[', field, ']')
end

function field_id(name, field)
end

function field_name(name, field)
end

function field_value(form, field; selected=false)
end

function build(tag::String, changeset::Union{Void,Changeset}, field::Symbol, opts; body=nothing, LF=false)
    result = "<$tag"
    for (k,v) in opts
        result *= string(' ', k, "=\"", isa(v, Function) ? v(changeset.model, field) : v, '"')
    end
    linefeed = LF ? "\n" : ""
    string(result, isa(body, Void) ? " />" : ">$linefeed$body</$tag>")
end

function form_for(block::Function, changeset::Changeset, args...; kw...)
    list = Vector{Tuple{Symbol,Union{Function,String}}}(vcat(args..., kw...))
    opts = Dict(list)
    if haskey(opts, :method)
        verb = opts[:method]
    else
        verb = get
        push!(list, (:method, get))
    end
    sym_accept_charset = Symbol("accept-charset")
    if !haskey(opts, sym_accept_charset)
        push!(list, (sym_accept_charset, "utf-8"))
    end

    function form_for_args(action, list::Vector)
        vec = Vector()
        for (k,v) in list
            if :action == k
                push!(vec, k=>action)
            elseif :method == k
                method = string(Base.function_name(v))
                push!(vec, k=>method)
            else
                push!(vec, k=>v)
            end
        end
        vec
    end

    build_form = (action) -> build("form", changeset, :form, form_for_args(action, list); body=block(changeset), LF=true)

    action = opts[:action]
    if isa(action, Function)
        for route in Bukdu.RouterRoute.routes
            if route.action == action && route.verb == verb
                return build_form(route.path)
            end
        end
        action_name = Base.function_name(action)
        method = string(Base.function_name(verb))
        throw(Bukdu.NoRouteError("not found a route for $action_name $method"))
    else
        return build_form(action)
    end
end

function value_from_changeset(changeset::Changeset, field::Symbol, value=nothing)
    if isa(value, Void)
        if haskey(changeset.changes, field)
            return changeset.changes[field]
        elseif field in fieldnames(typeof(changeset.model))
            return getfield(changeset.model, field)
        end
    end
    return nothing
end

function label(changeset::Changeset, field::Symbol, body=nothing; kw...)
    build("label", changeset, field, (:for=>tag_id, kw...); body=body)
end

function text_input(changeset::Changeset, field::Symbol, value=nothing; kw...)
    value = value_from_changeset(changeset, field, value)
    build("input", changeset, field, (:id=>tag_id, :name=>tag_name, :type=>"text", :value=>value, kw...))
end

function select_option(changeset::Changeset, field::Symbol, options, value=nothing)
    # broadcast #
    # string(join(string.("    <option value=\"", options, "\">", options, "</option>"), '\n'), '\n')
    selected_value = value_from_changeset(changeset, field, value)
    string(join(map(x->
        string("    <option value=\"", x, '"', (selected_value==x ? " selected" : ""), ">", x, "</option>"), options), '\n'), '\n')
end

function select(changeset::Changeset, field::Symbol, options, value=nothing; kw...)
    build("select", changeset, field, (:id=>tag_id, :name=>tag_name, kw...); body=select_option(changeset, field, options, value), LF=true)
end

function textarea(changeset::Changeset, field::Symbol, value=""; kw...)
    build("textarea", changeset, field, (:id=>tag_id, :name=>tag_name, kw...); body=value, LF=true)
end

function submit(value; kw...)
    build("input", nothing, :submit, (:type=>"submit", :value=>value, kw...))
end

end # module Bukdu.Tag
