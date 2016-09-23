# module Bukdu

module Tag

export form_for, label, text_input, select, submit

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

function form_for(block::Function, changeset::Changeset; kw...)
    kwd = Dict(kw)
    action = kwd[:action]
    verb = haskey(kwd, :method) ? kwd[:method] : get
    method = string(Base.function_name(verb))
    function form_for_args(action, method; kw...)
        args = Vector()
        for (k,v) in kw
            if :action == k
                push!(args, k=>action)
            elseif :method == k
                push!(args, k=>method)
            else
                push!(args, k=>v)
            end
        end
        tuple(args...)
    end
    if isa(action, Function)
        for route in Bukdu.RouterRoute.routes
            if route.action == action && route.verb == verb
                return build("form", changeset, :form, form_for_args(route.path, method; kw...); body=block(changeset), LF=true)
            end
        end
        action_name = Base.function_name(action)
        throw(Bukdu.NoRouteError("not found a route for $action_name $method"))
    else
        return build("form", changeset, :form, form_for_args(action, method; kw...); body=block(changeset), LF=true)
    end
end

function label(changeset::Changeset, field::Symbol, body=nothing)
    if isa(body,Void) && haskey(changeset.changes, field)
        body = changeset.changes[field]
    end
    build("label", changeset, field, (:for=>tag_id,); body=body)
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

function text_input(changeset::Changeset, field::Symbol, value=nothing)
    value = value_from_changeset(changeset, field, value)
    build("input", changeset, field, (:id=>tag_id, :name=>tag_name, :type=>"text", :value=>value))
end

function select_option(changeset::Changeset, field::Symbol, options, value=nothing)
    # broadcast #
    # string(join(string.("    <option value=\"", options, "\">", options, "</option>"), '\n'), '\n')
    selected_value = value_from_changeset(changeset, field, value)
    string(join(map(x->
        string("    <option value=\"", x, '"', (selected_value==x ? " selected" : ""), '>', x, "</option>"), options), '\n'), '\n')
end

function select(changeset::Changeset, field::Symbol, options, value=nothing)
    build("select", changeset, field, (:id=>tag_id, :name=>tag_name); body=select_option(changeset, field, options, value), LF=true)
end

function submit(value)
    build("input", nothing, :submit, (:type=>"submit", :value=>value))
end

end # module Bukdu.Tag
