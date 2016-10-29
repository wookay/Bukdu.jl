# module Bukdu.Octo.Query

import ..Database: Adapter, get_adapter
import ..pluralize

type From
    tables::Vector{Type} # <: Query.Model
end

type Select
    name::Symbol
    value::Any
end

type Parameter
    index::Int
    params::Tuple
end

Parameter() = Parameter(0, tuple())

type SubQuery
    from::From
    select::Select
    where::Nullable{Predicate}
    parameter::Parameter
end

type SubQueryError
    message
end

function subquery(from::From; kw...)::SubQuery # throw SubQueryError
    opts = Assoc(kw)
    select_names = intersect([:select, :select_distinct], keys(opts))
    if !isempty(select_names)
        name = first(select_names)
        value = opts[name]
        select = Select(name, value)
        if isa(value, Field) ||
           isa(value, Tuple) ||
           isa(value, Vector{Field})
            for table in Query.tables(value)
                !in(table, from.tables) && push!(from.tables, table)
            end
        end
    else
        select = Select(:select, *)
    end
    where = haskey(opts, :where) ? Nullable(opts[:where]) : Nullable{Predicate}()
    for table in Query.tables(where)
        !in(table, from.tables) && push!(from.tables, table)
    end
    if isempty(from.tables)
        throw(SubQueryError(""))
    else
        SubQuery(from, select, where, Parameter())
    end
end

function statement(subquery::SubQuery, args...)::String # throw NoAdapterError
    adapter = get_adapter()
    statement(adapter, subquery, args...)
end

function tables(field::Field)::Vector{Type}
    [field.typ]
end

function tables(tup::Tuple)::Vector{Type}
    collect(map(field -> field.typ, tup))
end

function tables(vec::Vector{Field})::Vector{Type}
    map(field -> field.typ, vec)
end

function tables(predicate::Nullable{Predicate})::Vector{Type}
    if isnull(predicate)
        Vector{Type}()
    else
        pred = predicate.value
        set = Set()
        for x in [pred.first, pred.second]
            isa(x, Field) && push!(set, x.typ)
            if isa(x, Predicate)
                for y in [x.first, x.second]
                    isa(y, Field) && push!(set, y.typ)
                end
            end
        end
        Vector(collect(set))
    end
end

function table_alias_name(tables::Vector{Type}, T::Type)::String
    table_name_chars = first.(Query.table_name.(tables))
    table_name_char = first(Query.table_name(T))
    if length(findin(table_name_chars, table_name_char)) > 1
        ind = findfirst(tables, T)
        string(table_name_char, ind)
    else
        string(table_name_char)
    end
end

in(field::Field, sub::SubQuery)::Predicate = Predicate(in, field, sub)
