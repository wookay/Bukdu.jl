# module Bukdu.Octo

module Query

export ComponentQuery, SubQuery, InsertQuery, UpdateQuery, DeleteQuery
export Predicate
export from
export and, or, not_in, is_null, is_not_null, like, not_like, between, exists, not_exists
export asc, desc
export ?

import ..Schema
import .Schema: Table, ColumnPhrase
import ..Assoc
import ..Field
import ..Inflector
import ..Logger
import Base: in, isless, ==, !, &, |

abstract Model
abstract RecordQuery

module A

import ....Octo
import .Octo: Schema, Query, Field

end # module Bukdu.Octo.Query.A

type ?
end

include("query/predicate.jl")
include("query/subquery.jl")
include("query/changequery.jl")
include("query/componentquery.jl")

models = Dict{Type, Query.Model}()
origin_types = Dict{Type, Type}() # {Type{<:Query.Model}, Type}

function from(; kw...)::SubQuery
    subquery(From([]); kw...)
end

function from(T::Type; kw...)::SubQuery
    subquery(From([T]); kw...)
end

function from{M<:Query.Model}(::M; kw...)::SubQuery
    from(origin_types[M]; kw...)
end

function proc_field_name_type(column::ColumnPhrase)::String
    string(column.name, "::", :Field)
end

function proc_field_name_type(schema_table::Table)::Vector{String}
    proc_field_name_type.(schema_table.columns)
end

function generate_query_model(T::Type, schema_table::Table)::Query.Model
    typ_name = T.name.name
    typ_name_uuid = replace(string(typ_name, '_', Base.Random.uuid1()), '-', '_')
    code = string("type $typ_name_uuid <: Query.Model", "\n",
                  join(map(phrase -> string("    ", phrase), proc_field_name_type(schema_table)), "\n"), "\n",
                  "end", "\n"
           )
    # Logger.info("query model code", code)
    eval(A, parse(code))
    eval(A, parse("$typ_name = $typ_name_uuid"))
    model_typ = getfield(A, typ_name)
    model = model_typ(map(schema_table.columns) do column
        Field(T, column.name, column.options)
    end...)
    models[T] = model
    origin_types[model_typ] = T
    model
end

function schema_table_name(T::Type)::String
    if applicable(Schema.table_name, T)
        Schema.table_name(T)
    else
        Inflector.tableize(string(T.name.name))
    end
end

function schema_table_alias_name(tables::Vector{Type}, T::Type)::String
    table_name_chars = first.(schema_table_name.(tables))
    table_name_char = first(schema_table_name(T))
    if length(findin(table_name_chars, table_name_char)) > 1
        ind = findfirst(tables, T)
        string(table_name_char, ind)
    else
        string(table_name_char)
    end
end

function in(block::Function, T::Type)::Query.Model
    table = Table(Vector{ColumnPhrase}())
    block(table)
    schema_table = Schema.build_schema_table(T, table)
    generate_query_model(T, schema_table)
end

function in(T::Type)::Query.Model
    typ_name = T.name.name
    if haskey(models, T)
        models[T]
    else
        table = Table(Vector{ColumnPhrase}())
        schema_table = Schema.build_schema_table(T, table)
        generate_query_model(T, schema_table)
    end
end

end # module Bukdu.Octo.Query
