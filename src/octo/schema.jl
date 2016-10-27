# module Bukdu.Octo

module Schema

export PrimaryKey, Field
export schema, has_many

import ..Assoc
import ..Logger
import Base: ==

abstract Model

relations = Dict{Type,Vector}()

type PrimaryKey{T}
    id::T
end

type Field
    typ::Type
    name::Symbol
end

module A

import ....Bukdu
import .Bukdu.Octo: Schema

end # module Bukdu.Octo.Schema.A

Base.convert{T}(::Type{PrimaryKey{T}}, id::T) = PrimaryKey{T}(id)
Base.convert(::Type{PrimaryKey}, id::Int) = PrimaryKey{Int}(id)

==(lhs::PrimaryKey, rhs::PrimaryKey) = ==(lhs.id, rhs.id)

function type_generate(T::Type)::Type # <: Schema.Model
    type_name = T.name.name
    lines = String[]
    fields = Assoc()
    for i in 1:nfields(T)
        typ = fieldtype(T, i)
        if typ <: PrimaryKey && isa(first(typ.parameters), TypeVar)
            paramtyp = first(typ.parameters)
            fieldtyp = isa(paramtyp, TypeVar) ? Int : paramtyp
        else
            fieldtyp = typ
        end
        push!(fields, (fieldname(T, i), fieldtyp))
    end
    if haskey(Schema.relations, T)
        for (relation,name,FT) in Schema.relations[T]
            push!(fields, (name, Base.Generator.name))
        end
    end
    push!(lines, "type $type_name <: Schema.Model")
    for (name,typ) in fields
        push!(lines, "    $name::$typ")
    end
    push!(lines, string("    ", type_name, "(", join(["$name::$typ" for (name,typ) in fields], ", "), ") = new(", join(keys(fields), ", "), ")"))
    push!(lines, "end")
    code = join(lines, "\n")
    eval(A, parse(code))
    getfield(A, type_name)
end

function schema(block::Function, T::Type)::Type # <: Schema.Model
    Schema.relations[T] = Vector()
    block(T)
    pooling_type(T)
end

function pooling_type(T::Type)::Type # <: Schema.Model
    type_name = T.name.name
    isdefined(A, type_name) ? getfield(A, type_name) : type_generate(T)
end

function has_many(T::Type, name::Symbol, FT::Type)
    push!(Schema.relations[T], (:has_many,name,FT))
end

end # module Bukdu.Octo.Schema

import .Schema: PrimaryKey, Field
import .Schema: schema, has_many
