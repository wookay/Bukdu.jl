# module Bukdu.Octo.Query

import ..Database: Adapter, NotImplementedError
import ..pluralize

type SubQuery
    from
    select
    where
end

type From
    tables::Vector{Type} # <: Query.Model
end

function subquery(from::From; kw...)::SubQuery
    opts = Dict(kw)
    select = haskey(opts, :select) ? opts[:select] : *
    where = haskey(opts, :where) ? opts[:where] : Predicate(identity,==,true,true)
    for table in Query.tables(where)
        !in(table, from.tables) && push!(from.tables, table)
    end
    SubQuery(from, select, where)
end

function statement{A<:Adapter}(::Type{A}, subquery::SubQuery)::String # throw NotImplementedError
    throw(NotImplementedError(""))
end

function table_name(T::Type)::String
    pluralize(lowercase(string(T.name.name)))
end

function table_alias_name(tables::Vector{Type}, T::Type)::String
    table_names = first.(table_name.(tables))
    string(first(table_name(T)))
end
