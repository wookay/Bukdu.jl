module Form # Bukdu.HTML5

export change
export form_for, label_for
export text_input, text_area, radio_button, checkbox
export submit

import ...Bukdu: ApplicationController, Assoc, Changeset, Router, Naming, post
import Documenter.Utilities.DOM: @tags, Node

"""
    change(M::Type, params::Assoc)::Changeset
"""
function change(M::Type, params::Assoc)::Changeset
    modelnameprefix = Naming.model_prefix(M)
    ntkeys = []
    ntvalues = []
    modelfieldnames = fieldnames(M)
    for (idx::Int, (k::String, v)) in pairs(params)
        if startswith(k, modelnameprefix)
            key = Symbol(k[length(modelnameprefix)+1:end])
            if key in modelfieldnames
                typ = fieldtype(M, key)
                push!(ntkeys, key)
                if typ === Any || typ === String
                    push!(ntvalues, v)
                else
                    push!(ntvalues, parse(typ, v))
                end
            elseif key != Symbol("")
                push!(ntkeys, key)
                push!(ntvalues, v)
            end
        end
    end
    changes = NamedTuple{tuple(ntkeys...)}(tuple(ntvalues...))
    Changeset(M, changes)
end

"""
    change(changeset::Changeset, params::Assoc; primary_key::Union{String,Nothing}=nothing)::Changeset
"""
function change(changeset::Changeset, params::Assoc; primary_key::Union{String,Nothing}=nothing)::Changeset
    p = change(changeset.model, params)
    nt = changeset.changes
    ntkeys = []
    ntvalues = []
    for (k::Symbol, v) in pairs(p.changes)
        if haskey(nt, k)
            typ = typeof(nt[k])
            if v isa typ
                val = v
            else
                val = parse(typ, v)
            end
            if val == nt[k]
                if !(primary_key isa Nothing) && Symbol(primary_key) == k
                    push!(ntkeys, k)
                    push!(ntvalues, val)
                end
            else
                push!(ntkeys, k)
                push!(ntvalues, val)
            end
        end
    end
    changes = NamedTuple{tuple(ntkeys...)}(tuple(ntvalues...))
    Changeset(changeset.model, changes)
end

"""
    form_for(block::Function, changeset::Changeset, controller_action::Tuple; method=post, kwargs...)::Node
"""
function form_for(block::Function, changeset::Changeset, controller_action::Tuple; method=post, kwargs...)::Node
    (C, action) = controller_action
    form_action = Router.Helpers.url_path(method, C, action)
    form_for(block, changeset, form_action; method=method, kwargs...)
end

"""
    form_for(block::Function, changeset::Changeset, form_action::String; method=post, multipart::Bool=false)::Node
"""
function form_for(block::Function, changeset::Changeset, form_action::String; method=post, multipart::Bool=false, kwargs...)::Node
    @tags form
    attrs = [:action => form_action, :method => Naming.verb_name(method), kwargs...]
    multipart && push!(attrs, :enctype => "multipart/form-data")
    fo = form[attrs...]
    result = block(changeset)
    result isa Nothing ? fo : fo(result)
end

"""
    label_for(node::Node, text::Union{String,Nothing}=nothing; kwargs...)::Vector{Node}
"""
function label_for(node::Node, text::Union{String,Nothing}=nothing; kwargs...)::Vector{Node}
    @tags label
    nt = NamedTuple{tuple(first.(node.attributes)...)}(tuple(getindex.(node.attributes, 2)...))
    fo = label[:for => nt.id, kwargs...]
    [node, text isa Nothing ? fo : fo(text)]
end

"""
    label_for(nodes::Vector{Node}, text::Union{String,Nothing}=nothing; kwargs...)::Vector{Node}
"""
function label_for(nodes::Vector{Node}, text::Union{String,Nothing}=nothing; kwargs...)::Vector{Node}
    @tags label
    node = last(nodes)
    nt = NamedTuple{tuple(first.(node.attributes)...)}(tuple(getindex.(node.attributes, 2)...))
    fo = label[:for => nt.id, kwargs...]
    [nodes..., text isa Nothing ? fo : fo(text)]
end

function _form_value_text(f::Changeset, field::Symbol, value) # text_input text_area
    if value isa Nothing
        get(f.changes, field, "")
    else
        value
    end
end

function _form_value_checkbox(f::Changeset, field::Symbol, value)
    if value isa Nothing
        get(f.changes, field, false)
    else
        value
    end
end

function _form_value_radio_button(f::Changeset, field::Symbol, value::String)
    get(f.changes, field, nothing) == value
end

"""
    text_input(f::Changeset, field::Symbol, value=nothing; kwargs...)::Node
"""
function text_input(f::Changeset, field::Symbol, value=nothing; kwargs...)::Node
    @tags input
    name = Naming.model_prefix(f.model, field)
    input[:id => name,
          :name => name,
          :type => "text",
          :value => _form_value_text(f, field, value),
          kwargs...]
end

"""
    text_area(f::Changeset, field::Symbol, value=nothing; kwargs...)::Node
"""
function text_area(f::Changeset, field::Symbol, value=nothing; kwargs...)::Node
    @tags textarea
    name = Naming.model_prefix(f.model, field)
    val = _form_value_text(f, field, value)
    textarea[:id => name,
             :name => name,
             kwargs...](val)
end

"""
    radio_button(f::Changeset, field::Symbol, value::String; kwargs...)::Node
"""
function radio_button(f::Changeset, field::Symbol, value::String; kwargs...)::Node
    @tags input
    input_id = Naming.model_prefix(f.model, field, value)
    name = Naming.model_prefix(f.model, field)
    checked = _form_value_radio_button(f, field, value) ? [:checked => "checked"] : []
    input[checked...,
          :id => input_id,
          :name => name,
          :type => "radio",
          :value => value,
          kwargs...]
end

"""
    checkbox(f::Changeset, field::Symbol, value::Union{Bool,Nothing}=nothing; kwargs...)::Vector{Node}
"""
function checkbox(f::Changeset, field::Symbol, value::Union{Bool,Nothing}=nothing; kwargs...)::Vector{Node}
    @tags input
    name = Naming.model_prefix(f.model, field)
    checked = _form_value_checkbox(f, field, value) ? [:checked => "checked"] : []
    [input[:name => name, :type => "hidden", :value => "false"]
     input[checked...,
           :id => name,
           :name => name,
           :type => "checkbox",
           :value => "true",
           kwargs...]]
end

"""
    submit(block_option; kwargs...)::Node
"""
function submit(block_option; kwargs...)::Node
    @tags button
    button[:type => "submit", kwargs...](block_option)
end


import Documenter.Utilities.DOM: TEXT

function _flatten(a, n::Node)::Vector
    if n.name === TEXT
        push!(a, n.text)
    else
        push!(a, n.name)
        push!(a, n.attributes)
        for each in n.nodes
            _flatten(a, each)
        end
    end
    a
end

function Base.:(==)(a::Node, b::Node)::Bool
    _flatten([], a) == _flatten([], b)
end

end # module Bukdu.HTML5.Form
