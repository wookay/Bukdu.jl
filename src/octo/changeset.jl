# module Bukdu.Octo

export default, Changeset, |>, change, cast, validate_length

default(T::Type, ::Type{String}) = ""
default(T::Type, ::Type{Int}) = 0

function default(T::Type)::T
    # broadcast #
    # fields = fieldtype.(T,fieldnames(T))
    # T(default.(T, fields)...)
    fields = map(x->fieldtype(T, x), fieldnames(T))
    T(map(x-> default(T, x), fields)...)
end


type Changeset
    model
    changes
end

function |>(changeset::Changeset, func::Function)
    func(changeset)
end

function |>(model, func::Function)
    func(change(model))
end

function change(model; kw...)::Changeset
    Changeset(model, [])
end

function cast(changeset::Changeset, params, required_fields)::Changeset
    changeset
end

function validate_length(changeset::Changeset, field::Symbol; kw...)::Changeset
    changeset
end

function cast(params, required_fields)::Function
    (changeset) -> cast(changeset, params, required_fields)
end

function validate_length(field::Symbol; kw...)::Function
    (changeset) -> validate_length(changeset, field; kw...)
end
