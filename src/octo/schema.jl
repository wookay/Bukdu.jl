# module Bukdu.Octo

module Schema

export PrimaryKey, Field
export add, has_many, has_one, belongs_to
export create, create_if_not_exists, rename, alter, drop

import ..Assoc
import ..Inflector
import ..Logger
import Base: ==

abstract Model

type PrimaryKey{T}
    id::T
end

type Field
    typ::Type
    name::Symbol
    options::Dict{Symbol,Any}
end

type ColumnPhrase
    action::Symbol
    typ::Type
    name::Symbol
    options::Dict{Symbol,Any}
end

type Table
    columns::Vector{ColumnPhrase}
end

type ComponentQuery
    action::Function # create, create_if_not_exists, rename, alter, drop
    kind::Symbol     # :table, :index, :constraint
    table_name::String
    table::Nullable{Table}
    options::Dict
end

module A

import ....Octo
import .Octo: Schema
import .Schema: PrimaryKey

end # module Bukdu.Octo.Schema.A

Base.convert{T}(::Type{PrimaryKey{T}}, id::T) = PrimaryKey{T}(id)
Base.convert(::Type{PrimaryKey}, id::Int) = PrimaryKey{Int}(id)
Base.convert(::Type{PrimaryKey}, id::Int32) = PrimaryKey{Int}(id)

==(lhs::PrimaryKey, rhs::PrimaryKey) = ==(lhs.id, rhs.id)

function create(block::Function, kind::Symbol, name::String)::ComponentQuery
    table = Table(Vector{ColumnPhrase}())
    block(table)
    ComponentQuery(create, kind, name, Nullable(table), Dict())
end

function create_if_not_exists(block::Function, kind::Symbol, name::String)::ComponentQuery
    table = Table(Vector{ColumnPhrase}())
    block(table)
    ComponentQuery(create_if_not_exists, kind, name, Nullable(table), Dict())
end

function rename(kind::Symbol, name::String, to::String)::ComponentQuery
    ComponentQuery(rename, kind, name, Nullable{Table}(); Dict(:to=>to))
end

function alter(block::Function, kind::Symbol, name::String)::ComponentQuery
    table = Table(Vector{ColumnPhrase}())
    block(table)
    ComponentQuery(alter, kind, name, Nullable(table), Dict())
end

function drop(kind::Symbol, name::String)::ComponentQuery
    ComponentQuery(drop, kind, name, Nullable{Table}(), Dict())
end

function push_column_phrase(table::Table, action::Symbol, typ::Type, name::Symbol; kw...)
    column = ColumnPhrase(action, typ, name, Dict(kw))
    push!(table.columns, column)
end

function add(table::Table, name::Symbol, typ::Type; kw...)
    push_column_phrase(table, :add, typ, name; kw...)
end

function modify(table::Table, name::Symbol, typ::Type; kw...)
    push_column_phrase(table, :modify, typ, name; kw...)
end

function remove(table::Table, name::Symbol; kw...)
    push_column_phrase(table, :remove, Void, name; kw...)
end

function has_many(table::Table, name::Symbol, typ::Type; kw...)
    push_column_phrase(table, :has_many, typ, name; kw...)
end

function has_one(table::Table, name::Symbol, typ::Type; kw...)
    push_column_phrase(table, :has_one, typ, name; kw...)
end

function belongs_to(table::Table, name::Symbol, typ::Type; kw...)
    push_column_phrase(table, :belongs_to, typ, name; kw...)
end

function proc_field_name_type(column::ColumnPhrase)::String
    if isempty(column.typ.parameters)
        type_params = ""
    else
        type_params = string('{', join(map(column.typ.parameters) do param
            if isa(param, TypeVar)
                :PrimaryKey == column.typ.name.name ? Int : Any
            elseif isa(param, Type)
                isdefined(A, column.typ.name.name) ? column.typ.name.name : Any
            else
                param
            end
        end, ','), '}')
    end
    string(column.name, "::", column.typ.name.name, type_params)
end

function proc_field_name_type(schema_table::Table)::Vector{String}
    proc_field_name_type.(schema_table.columns)
end

function build_schema_table(T::Type, table::Table)::Table
    schema_table = Table(Vector{ColumnPhrase}())
    for i in 1:nfields(T)
        name = fieldname(T, i)
        in(name, map(column -> column.name, table.columns)) && continue
        typ = fieldtype(T, i)
        push!(schema_table.columns, ColumnPhrase(:type, typ, name, Dict{Symbol,Any}()))
    end
    for column in table.columns
        if :belongs_to == column.action
            col = ColumnPhrase(column.action, column.typ, string(column.name, "_id"), column.options)
            push!(schema_table.columns, col)
        else
            push!(schema_table.columns, column)
        end
    end
    schema_table
end

function generate_schema_model(T::Type, schema_table::Table)::Type # <: Schema.Model
    typ_name = T.name.name
    typ_name_uuid = replace(string(typ_name, '_', Base.Random.uuid1()), '-', '_')
    code = string("type $typ_name_uuid <: Schema.Model", "\n",
                  join(map(phrase -> string("    ", phrase), proc_field_name_type(schema_table)), "\n"), "\n",
                  "end", "\n"
           )
    Logger.info("schema model code", code)
    eval(A, parse(code))
    eval(A, parse("$typ_name = $typ_name_uuid"))
    getfield(A, typ_name)
end

function table_name
end

end # module Bukdu.Octo.Schema

import .Schema: PrimaryKey, Field
import .Schema: add, has_many, has_one, belongs_to
