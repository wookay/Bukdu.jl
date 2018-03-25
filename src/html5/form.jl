module Form # Bukdu.HTML5

export change, form_for, text_input, submit

import ...Bukdu: ApplicationController, Assoc, Changeset, Routing, Naming, post
import Documenter.Utilities.DOM: @tags

function model_prefix(M::Type)::String
    string(lowercase(String(nameof(M))), '_')
end

function model_prefix(M::Type, field::Symbol)::String
    string(model_prefix(M), field)
end

"""
    change
"""
function change(M::Type, params::Assoc)::Changeset
    modelnameprefix = model_prefix(M)
    ntkeys = []
    ntvalues = []
    modelfieldnames = fieldnames(M)
    for (k::String, v) in pairs(params)
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

function change(M::Type, nt::NamedTuple, params::Assoc; primary_key::String)::Changeset
    p = change(M, params)
    pk = Symbol(primary_key)
    ntkeys = []
    ntvalues = []
    for (k::Symbol, v) in pairs(p.changes)
        if haskey(nt, k)
            if v != nt[k]
                 push!(ntkeys, k)
                 typ = typeof(nt[k])
                 if v isa typ
                     push!(ntvalues, v)
                 else
                     push!(ntvalues, parse(typ, v))
                 end
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

function text_input(f::Changeset, field::Symbol, value="")
    @tags input
    input[:id => model_prefix(f.model, field),
          :name => model_prefix(f.model, field),
          :type => "text",
          :value => value]()
end

function submit(block_option)
    @tags button
    button[:type => "submit"](block_option)
end

end # module Bukdu.HTML5.Form
