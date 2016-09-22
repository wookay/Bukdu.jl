# module Bukdu

module Tag

import ....Bukdu

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

function build(tag::String, f, field::Symbol, opts; body=nothing, LF=false)
    result = "<$tag"
    for (k,v) in opts
        result *= string(' ', k, "=\"", isa(v, Function) ? v(f, field) : v, '"')
    end
    linefeed = LF ? "\n" : ""
    string(result, isa(body, Void) ? " />" : ">$linefeed$body</$tag>")
end

function form_for(block::Function, f; kw...)
    kwd = Dict(kw)
    action = kwd[:action]
    verb = haskey(kwd, :method) ? kwd[:method] : get
    method = string(Base.function_name(verb))
    if isa(action, Function)
        for route in Bukdu.RouterRoute.routes
            if route.action == action && route.verb == verb
                return build("form", f, :form, (:action=>route.path, :method=>method); body=block(f), LF=true)
            end
        end
        action_name = Base.function_name(action)
        throw(Bukdu.NoRouteError("not found a route for $action_name $method"))
    else
        return build("form", f, :form, (:action=>action, :method=>method); body=block(f), LF=true)
    end
end

function label(f, field::Symbol, body)
    build("label", f, field, (:for=>tag_id,); body=body)
end

function text_input(f, field::Symbol, value="")
    build("input", f, field, (:id=>tag_id, :name=>tag_name, :type=>"text", :value=>value))
end

function select_option(options)
    # broadcast #
    # string(join(string.("    <option value=\"", options, "\">", options, "</option>"), '\n'), '\n')
    string(join(map(x-> string("    <option value=\"", x, "\">", x, "</option>"), options), '\n'), '\n')
end

function select(f, field::Symbol, options)
    build("select", f, field, (:id=>tag_id, :name=>tag_name); body=select_option(options), LF=true)
end

function submit(value)
    build("input", nothing, :submit, (:type=>"submit", :value=>value))
end

end # module Bukdu.Tag
