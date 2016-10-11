# module Bukdu.Octo

import ..Bukdu
import Bukdu: ApplicationController
import Bukdu: Logger
import Base: ==

type Changeset
    model
    changes::Assoc
    function Changeset(model, changes::Assoc)
        T = typeof(model)
        lhs = Assoc(map(x->(x, getfield(model, x)), fieldnames(T)))
        rhs = typed_assoc(T, changes)
        new(model, setdiff(rhs, lhs))
    end
end

function ==(lhs::Changeset, rhs::Changeset)
    T = typeof(lhs.model)
    !isa(rhs.model, T) && return false
    all(x -> ==(getfield(lhs.model, x), getfield(rhs.model, x)), fieldnames(T)) &&
             ==(lhs.changes, rhs.changes)
end

function |>(changeset::Changeset, func::Function)
    func(changeset)
end

function |>(model, func::Function)
    func(change(model))
end

function typed_assoc(T::Type, changes::Assoc)::Assoc
    typ_fieldnames = fieldnames(T)
    Assoc(
        map(filter(kv -> first(kv) in typ_fieldnames, changes)) do kv
            (name, value) = kv
            if name in typ_fieldnames
                fieldT = fieldtype(T, name)
                if isa(value, fieldT)
                    (name, value)
                else
                    (name, parse(fieldT, value))
                end
            end
        end)
end

function cutout_brackets(T::Type, param::Tuple{Symbol,Any})::Tuple{Symbol,Any}
    typ = lowercase(string(T.name.name))
    (key, value) = param
    name = string(key)
    if endswith(name, "]")
        name = first(split(name, "["))
    end
    if startswith(name, "$(typ)_")
        key = Symbol(name[length("$(typ)_")+1:end])
    end
    (key, value)
end

"""
    change(model)::Changeset

Get the changeset of the model.
"""
function change(model; kw...)::Changeset
    Changeset(model, Assoc(kw))
end

"""
    change(typ::Type)::Changeset

Get the changeset of the Type.
"""
function change(typ::Type; kw...)::Changeset
    change(default(typ); kw...)
end

function change(typ::Void; kw...)::Changeset # throw ArgumentError
    throw(ArgumentError("not allowd for Void model"))
end

function change{T<:Any,AC<:ApplicationController}(c::AC, model::T)::Changeset
    params = map(param->cutout_brackets(T,param), c[:query_params])
    assoc = Assoc(params)
    for name in fieldnames(T)
        typ = fieldtype(T, name)
        if typ <: Vector
            assoc = combine(typ, assoc, name)
        elseif Bool==typ && !haskey(assoc, name)
            assoc[name] = default(T, typ)
        end
    end
    Changeset(model, assoc)
end

function change{AC<:ApplicationController}(c::AC, T::Type)::Changeset
    change(c, default(T))
end

default(T::Type, ::Type{String}) = ""
default(T::Type, ::Type{Int}) = 0
default(T::Type, ::Type{Float64}) = 0.0
default(T::Type, ::Type{Float32}) = 0.0
default(T::Type, ::Type{Bool}) = false
default(T::Type, ::Type{Vector{String}}) = Vector{String}()

function default(T::Type)::T
    # broadcast #
    # fields = fieldtype.(T, fieldnames(T))
    # T(default.(T, fields)...)
    fields = map(x->fieldtype(T, x), fieldnames(T))
    T(map(x-> default(T, x), fields)...)
end

function cast(changeset::Changeset, params, required_fields)::Changeset
    changeset
end

function cast(params, required_fields)::Function
    (changeset) -> cast(changeset, params, required_fields)
end


function validates(model, params)
    throw(MethodError("Please define the `function validates(model::$(typeof(model)), params)`"))
end

function validate_length(changeset::Changeset, field::Symbol; kw...)::Changeset
    changeset
end

function validate_length(field::Symbol; kw...)::Function
    (changeset) -> validate_length(changeset, field; kw...)
end
