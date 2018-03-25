module Form # Bukdu.HTML5

export change, form_for, text_input, submit

import ...Bukdu: ApplicationController, Assoc, Changeset, Routing, Naming, post
import Documenter.Utilities.DOM: @tags

"""
    change
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

function change(M::Type, nt::NamedTuple, params::Assoc; primary_key::Union{String,Nothing}=nothing)::Changeset
    p = change(M, params)
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
    Changeset(M, changes)
end

function form_for(f, changeset::Changeset, controller_action::Tuple; method=post, kwargs...)
    (controller, action) = controller_action
    form_action = Routing.route(method, controller, action)
    form_for(f, changeset, form_action; method=method, kwargs...)
end

function form_for(f, changeset::Changeset, form_action::String; method=post, multipart::Bool=false)
    @tags form
    attrs = [:action => form_action, :method => Naming.verb_name(method)]
    multipart && push!(attrs, :enctype => "multipart/form-data")
    form[attrs...](f(changeset))
end

function form_value(f::Changeset, field::Symbol, value)
    if value isa Nothing
        get(f.changes, field, "")
    else
        value
    end
end

function text_input(f::Changeset, field::Symbol, value=nothing)
    @tags input
    input[:id => Naming.model_prefix(f.model, field),
          :name => Naming.model_prefix(f.model, field),
          :type => "text",
          :value => form_value(f, field, value)]()
end

function submit(block_option)
    @tags button
    button[:type => "submit"](block_option)
end

end # module Bukdu.HTML5.Form
