# module Bukdu.Octo

module Schema

export PrimaryKey, Field
export schema, table_name, field, has_many, has_one, belongs_to

import ..Assoc
import ..Logger
import ..pluralize
import Base: ==

abstract Model

relations = Dict{Symbol,Vector}()

type PrimaryKey{T}
    id::T
end

type Field
    typ::Type
    name::Symbol
end

module A

import ....Octo
import .Octo: Schema

end # module Bukdu.Octo.Schema.A

Base.convert{T}(::Type{PrimaryKey{T}}, id::T) = PrimaryKey{T}(id)
Base.convert(::Type{PrimaryKey}, id::Int) = PrimaryKey{Int}(id)
Base.convert(::Type{PrimaryKey}, id::Int32) = PrimaryKey{Int}(id)

==(lhs::PrimaryKey, rhs::PrimaryKey) = ==(lhs.id, rhs.id)

function origin_type
end

function type_generate(T::Type)::Type # <: Schema.Model
    type_name = T.name.name
    type_name_uuid = replace(string(type_name, '_', Base.Random.uuid1()), '-', '_')
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
    if haskey(Schema.relations, type_name)
        for (relation,name,FT) in Schema.relations[type_name]
            if :has_many == relation
                push!(fields, (name, Base.Generator.name))
            elseif :belongs_to == relation
                push!(fields, (Symbol("$(name)_id"), Int))
            else # :has_one
                push!(fields, (name, FT))
            end
        end
    end
    push!(lines, "type $type_name_uuid <: Schema.Model")
    for (name,typ) in fields
        push!(lines, "    $name::$typ")
    end
    push!(lines, string("    ", type_name, "(", join(["$name::$typ" for (name,typ) in fields], ", "), ") = new(", join(keys(fields), ", "), ")"))
    push!(lines, "end")
    code = join(lines, "\n")
    #Logger.info("code", code)
    eval(A, parse(code))
    eval(A, parse("$type_name = $type_name_uuid"))
    getfield(A, type_name)
end

function pooling_type(T::Type)::Type # <: Schema.Model
    typ_name = T.name.name
    isdefined(A, typ_name) ? getfield(A, typ_name) : type_generate(T)
end

function schema(block::Function, T::Type)::Type # <: Schema.Model
    typ_name = T.name.name
    Schema.relations[typ_name] = Vector()
    block(T)
    pooling_type(T)
end

function table_name(T::Type)::String
    typ_name = string(T.name.name)
    pluralize(lowercase(typ_name))
end

function field(T::Type, name::Symbol; kw...)
    typ_name = T.name.name
    push!(Schema.relations[typ_name], (:field, name, kw))
end

function has_many(T::Type, name::Symbol, FT::Type; kw...)
    typ_name = T.name.name
    push!(Schema.relations[typ_name], (:has_many, name, FT))
end

function has_one(T::Type, name::Symbol, FT::Type; kw...)
    typ_name = T.name.name
    push!(Schema.relations[typ_name], (:has_one, name, FT))
end

function belongs_to(T::Type, name::Symbol, FT::Type; kw...)
    typ_name = T.name.name
    push!(Schema.relations[typ_name], (:belongs_to, name, FT))
end

end # module Bukdu.Octo.Schema

import .Schema: PrimaryKey, Field
import .Schema: schema, table_name, field, has_many, has_one, belongs_to
