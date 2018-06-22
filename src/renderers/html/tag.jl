# module Bukdu

module Tag

export form_for, label, text_input, select, checkbox, radio_button, textarea, file_input, hidden_input, submit
export uploaded_image, hidden_csrf_token

import ....Bukdu
import Bukdu.Octo: Changeset, change
import Bukdu: Assoc, Plug, ApplicationController
import Bukdu: Conn, ApplicationError
import Bukdu: put_status, check_controller_has_field_conn
import Bukdu: Logger, get_datatype_name
import Base: select

immutable FormBuildError <: ApplicationError
    conn::Conn
    message::String
end

const ChangesetOrVoid = Union{Changeset, Void}

function tag_id(model, field, value)
    tag_name(model, field, value)
end

function tag_id_radio(model, field, value)
    string(tag_name(model, field, value), "[", value, "]")
end

function tag_name(model, field, value)
    typ = typeof(model)
    name = string(lowercase(string(get_datatype_name(typ))), '_', field)
    if fieldtype(typ, field) <: Vector
        string(name, "[", value, "]")
    else
        name
    end
end

function build(tag::String, changeset::ChangesetOrVoid, field::Symbol, opts; body=nothing, LF=false)
    result = "<$tag"
    options = Assoc(opts)
    value = haskey(options, :value) ? options[:value] : nothing
    for (k,v) in opts
        if !isa(v, Void)
            result *= string(' ', k, "=\"", isa(v, Function) ? (isa(changeset,Void) ? field : v(changeset.model, field, value)) : v, '"')
        end
    end
    linefeed = LF ? "\n" : ""
    string(result, isa(body, Void) ? " />" : ">$linefeed$body</$tag>")
end

function form_for(block::Function, changeset::ChangesetOrVoid, args...; kw...) # throw FormBuildError
    list = Vector{Tuple{Symbol,Union{Function,String,Bool}}}(vcat(args..., kw...))
    opts = Dict(list)
    if haskey(opts, :method)
        verb = opts[:method]
    else
        verb = get
        push!(list, (:method, get))
    end
    if haskey(opts, :multipart) && opts[:multipart]
        push!(list, (:enctype, "multipart/form-data"))
    end
    sym_accept_charset = Symbol("accept-charset")
    if !haskey(opts, sym_accept_charset)
        push!(list, (sym_accept_charset, "utf-8"))
    end

    function form_for_args(action, list::Vector)::Tuple
        vec = Vector()
        for (k,v) in list
            if :action == k
                push!(vec, k=>action)
            elseif :method == k
                method = string(Base.function_name(v))
                push!(vec, k=>method)
            elseif :multipart == k
            else
                push!(vec, k=>v)
            end
        end
        tuple(vec...)
    end

    build_form = (action) -> build("form", changeset, :form, form_for_args(action, list); body=block(changeset), LF=true)
    action = opts[:action]
    if isa(action, Function)
        for route in Bukdu.Routing.routes
            if route.action == action && route.verb == verb
                return build_form(route.path)
            end
        end
        action_name = Base.function_name(action)
        method = string(Base.function_name(verb))
        conn = Conn()
        put_status(conn, :internal_server_error)
        throw(FormBuildError(conn, "not found a route for $action_name $method"))
    else
        return build_form(action)
    end
end

function value_from_changeset(changeset::ChangesetOrVoid, field::Symbol, value=nothing)
    if isa(changeset,Changeset) && isa(value, Void)
        if haskey(changeset.changes, field)
            return changeset.changes[field]
        elseif field in fieldnames(typeof(changeset.model))
            return getfield(changeset.model, field)
        end
    end
    return value
end

function label(changeset::ChangesetOrVoid, field::Symbol, body=nothing; kw...)
    build("label", changeset, field, (:for=>tag_id, kw...); body=body)
end

function label(block::Function, changeset::Changeset, field::Symbol; kw...)
    label(changeset, field, body=block(); kw...)
end

function text_input(changeset::ChangesetOrVoid, field::Symbol; value=nothing, kw...)
    value = value_from_changeset(changeset, field, value)
    build("input", changeset, field, (:id=>tag_id, :name=>tag_name, :type=>"text", :value=>value, kw...))
end

function select_option(changeset::ChangesetOrVoid, field::Symbol, options, value=nothing)
    # broadcast #
    # string(join(string.("    <option value=\"", options, "\">", options, "</option>"), '\n'), '\n')
    value = value_from_changeset(changeset, field, value)
    string(join(map(x->
        string("    <option value=\"", x, '"', (value==x ? " selected" : ""), ">", x, "</option>"), options), '\n'), '\n')
end

function select(changeset::ChangesetOrVoid, field::Symbol, options; value=nothing, kw...)
    build("select", changeset, field, (:id=>tag_id, :name=>tag_name, kw...); body=select_option(changeset, field, options, value), LF=true)
end

function label_for_body(tag_id_func::Function, changeset::ChangesetOrVoid, field::Symbol, value::Any; kw...)::Tuple{Any,Tuple}
    opts = Assoc(kw)
    if haskey(opts, :label_for)
        tagid = tag_id_func(changeset.model, field, value)
        lab = opts[:label_for]
        delete!(opts, :label_for)
        ("""<label for="$tagid">$lab</label>""", tuple(opts...))
    else
        (nothing, tuple(kw...))
    end
end

function checkbox(changeset::ChangesetOrVoid, field::Symbol; kw...)
    checkbox(changeset, field, "true"; kw...)
end

function checkbox(changeset::ChangesetOrVoid, field::Symbol, value::Any; kw...)
    v = value_from_changeset(changeset, field, nothing)
    if isa(v, Vector)
        checked = value in v ? "checked" : nothing
    else
        checked = value == string(v) ? "checked" : nothing
    end
    (body,rest) = label_for_body(tag_id, changeset, field, value; kw...)
    build("input", changeset, field, (:id=>tag_id, :name=>tag_name, :type=>"checkbox", :checked=>checked, :value=>value); body=body, rest...)
end

function radio_button(changeset::ChangesetOrVoid, field::Symbol, value::Any; kw...)
    v = value_from_changeset(changeset, field, nothing)
    checked = v==value ? "checked" : nothing
    (body,rest) = label_for_body(tag_id_radio, changeset, field, value; kw...)
    build("input", changeset, field, (:id=>tag_id_radio, :name=>tag_name, :type=>"radio", :checked=>checked, :value=>value); body=body, rest...)
end

function textarea(changeset::ChangesetOrVoid, field::Symbol; value="", kw...)
    build("textarea", changeset, field, (:id=>tag_id, :name=>tag_name, kw...); body=value, LF=true)
end

function file_input(changeset::ChangesetOrVoid, field::Symbol; kw...)
    build("input", changeset, field, (:id=>tag_id, :name=>tag_name, :type=>"file", kw...))
end

function hidden_input(changeset::ChangesetOrVoid, field::Symbol; value=nothing, kw...)
    value = value_from_changeset(changeset, field, value)
    build("input", changeset, field, (:id=>tag_id, :name=>tag_name, :type=>"hidden", :value=>value, kw...))
end

function submit(value; kw...)
    build("input", nothing, :submit, (:type=>"submit", :value=>value, kw...))
end

function uploaded_image(changeset::Changeset, field::Symbol)
    if haskey(changeset.changes, field)
        upload = changeset.changes[field]
        if startswith(upload.content_type, "image") && Plug.UploadData.plugged()
            path = Plug.UploadData.upload_path(upload)
            alt = upload.filename
            return """<img src="$path" alt="$alt" title="$alt" />"""
        end
    end
    ""
end

function hidden_csrf_token{AC<:ApplicationController}(c::AC)
    check_controller_has_field_conn(c)
    hidden_input(nothing, :_csrf_token, value=Plug.csrf_token(c.conn))
end

end # module Bukdu.Tag
